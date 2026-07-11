//
//  NoCanvasViewModel.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 11/07/26.
//

import SwiftUI
import SwiftData
import PhotosUI

@Observable
final class NoCanvasViewModel {

    var photosPickerItem: PhotosPickerItem?
    var isProcessingPhoto = false

    private let backgroundRemovalService = BackgroundRemovalService()

    // MARK: - Entry points

    /// Alur galeri (dipakai NoCanvasView & sheet konfirmasi "Choose Photo").
    func handlePickedFullBodyPhoto(
        in context: ModelContext,
        onCanvasCreated: @escaping (CanvasDataModel) -> Void
    ) {
        guard let item = photosPickerItem else { return }
        isProcessingPhoto = true

        Task {
            defer { photosPickerItem = nil }

            guard let data = try? await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                isProcessingPhoto = false
                return
            }
            await processFullBodyImage(uiImage, in: context, onCanvasCreated: onCanvasCreated)
        }
    }

    /// Alur kamera (dipakai NoCanvasView & sheet konfirmasi "Retake Photo").
    func handleCapturedFullBodyPhoto(
        _ image: UIImage?,
        in context: ModelContext,
        onCanvasCreated: @escaping (CanvasDataModel) -> Void
    ) {
        guard let image else { return }
        isProcessingPhoto = true

        Task {
            await processFullBodyImage(image, in: context, onCanvasCreated: onCanvasCreated)
        }
    }

    /// Alur "Proceed" di sheet konfirmasi: pakai foto profil terakhir apa
    /// adanya (tanpa proses ulang), langsung buat canvas.
    func proceedWithExistingPhoto(
        in context: ModelContext,
        onCanvasCreated: (CanvasDataModel) -> Void
    ) {
        let descriptor = FetchDescriptor<UserFullBodyImageModel>()
        guard let photoData = try? context.fetch(descriptor).first?.fullBodyPicData else { return }
        createCanvas(withPhotoData: photoData, in: context, onCanvasCreated: onCanvasCreated)
    }

    // MARK: - Proses bersama

    /// Remove background → update profil (template foto terbaru) →
    /// buat canvas dengan SNAPSHOT foto itu.
    private func processFullBodyImage(
        _ uiImage: UIImage,
        in context: ModelContext,
        onCanvasCreated: @escaping (CanvasDataModel) -> Void
    ) async {
        defer { isProcessingPhoto = false }

        do {
            let processedImage = try await backgroundRemovalService.removeBackground(from: uiImage)
            guard let photoData = processedImage.pngData() else { return }

            // Update profil: template untuk canvas-canvas BERIKUTNYA.
            let descriptor = FetchDescriptor<UserFullBodyImageModel>()
            if let profile = try? context.fetch(descriptor).first {
                profile.fullBodyPicData = photoData
            } else {
                context.insert(UserFullBodyImageModel(fullBodyPicData: photoData))
            }

            createCanvas(withPhotoData: photoData, in: context, onCanvasCreated: onCanvasCreated)
        } catch {
            print("⚠️ Background removal gagal: \(error)")
        }
    }

    private func createCanvas(
        withPhotoData photoData: Data,
        in context: ModelContext,
        onCanvasCreated: (CanvasDataModel) -> Void
    ) {
        let newCanvas = CanvasDataModel(name: "Untitled", fullBodyPicData: photoData)
        context.insert(newCanvas)
        onCanvasCreated(newCanvas)
    }
}

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

    /// "Titipan": foto badan yang sudah diproses, menunggu user memilih
    /// baju di library. Canvas BELUM dibuat selama masih di sini —
    /// kalau user batal dari library, titipan dibuang, tidak ada jejak.
    private(set) var pendingPhotoData: Data?

    private let backgroundRemovalService = BackgroundRemovalService()

    // MARK: - Entry points (galeri / kamera / pakai foto lama)

    func handlePickedFullBodyPhoto(
        in context: ModelContext,
        onPhotoReady: @escaping () -> Void
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
            await processFullBodyImage(uiImage, in: context, onPhotoReady: onPhotoReady)
        }
    }

    func handleCapturedFullBodyPhoto(
        _ image: UIImage?,
        in context: ModelContext,
        onPhotoReady: @escaping () -> Void
    ) {
        guard let image else { return }
        isProcessingPhoto = true

        Task {
            await processFullBodyImage(image, in: context, onPhotoReady: onPhotoReady)
        }
    }

    /// "Proceed" di sheet konfirmasi: pakai foto profil terakhir tanpa
    /// proses ulang — langsung jadi titipan.
    func proceedWithExistingPhoto(in context: ModelContext, onPhotoReady: () -> Void) {
        let descriptor = FetchDescriptor<UserFullBodyImageModel>()
        guard let photoData = try? context.fetch(descriptor).first?.fullBodyPicData else { return }
        pendingPhotoData = photoData
        onPhotoReady()
    }

    // MARK: - Proses foto (remove bg + update template profil + titip)

    private func processFullBodyImage(
        _ uiImage: UIImage,
        in context: ModelContext,
        onPhotoReady: @escaping () -> Void
    ) async {
        defer { isProcessingPhoto = false }

        do {
            let processed = try await backgroundRemovalService.removeBackground(from: uiImage)
            guard let photoData = processed.pngData() else { return }

            // Update profil = template untuk canvas berikutnya (tetap!)
            let descriptor = FetchDescriptor<UserFullBodyImageModel>()
            if let profile = try? context.fetch(descriptor).first {
                profile.fullBodyPicData = photoData
            } else {
                context.insert(UserFullBodyImageModel(fullBodyPicData: photoData))
            }

            pendingPhotoData = photoData
            onPhotoReady()
        } catch {
            print("⚠️ Background removal gagal: \(error)")
        }
    }

    // MARK: - Kelahiran canvas (dipanggil dari onConfirm library)

    func createCanvas(
        with selectedItems: Set<ClothingItem>,
        in context: ModelContext,
        onCreated: (CanvasDataModel) -> Void
    ) {
        guard let photoData = pendingPhotoData else { return }

        let newCanvas = CanvasDataModel(name: "Untitled", fullBodyPicData: photoData)
        context.insert(newCanvas)

        // Pilihan baju -> CanvasItemModel, sesuai jenis sumbernya
        for item in selectedItems {
            let canvasItem: CanvasItemModel
            switch item.source {
            case .bundled(let assetName):
                canvasItem = CanvasItemModel(assetName: assetName)      // referensi (hemat)
            case .userUpload(_, let imageData):
                canvasItem = CanvasItemModel(imageData: imageData)      // salinan (snapshot)
            }
            canvasItem.sourceID = item.id 
            context.insert(canvasItem)
            canvasItem.canvas = newCanvas
        }

        pendingPhotoData = nil
        onCreated(newCanvas)
    }

    /// User batal dari library → buang titipan.
    func cancelPendingSelection() {
        pendingPhotoData = nil
    }
}

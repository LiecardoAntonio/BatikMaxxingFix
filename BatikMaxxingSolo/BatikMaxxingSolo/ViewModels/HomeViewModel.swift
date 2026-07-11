//
//  HomeViewModel.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 09/07/26.
//

import SwiftUI
import SwiftData
import PhotosUI

@Observable
final class HomeViewModel {
    
    // All this for the NoCanvasView part
    var photosPickerItem: PhotosPickerItem?
    var isProcessingPhoto = false

    // Dua ini yang jadi "sinyal" ke HomeView untuk navigasi ke CanvasView
    // begitu proses selesai (lihat .navigationDestination(item:) di HomeView).
    var activeCanvas: CanvasDataModel?
    var activeCanvasBodyImage: UIImage?

    private let backgroundRemovalService = BackgroundRemovalService()

    /// ModelContext dikirim sebagai parameter (bukan disimpan sebagai
    /// property) — pola yang sama dengan yang kita bahas sebelumnya,
    /// supaya tidak bergantung pada timing @Environment saat init.
    
    // this part belongs to CanvasGridView variables, i know i should've separate it:), maybe later, okay
    // State untuk alur rename
    var canvasToRename: CanvasDataModel?
    var renameText: String = ""
    var isRenamePresented: Bool = false
    
    // State untuk konfirmasi delete
    var canvasToDelete: CanvasDataModel?
    var isDeleteConfirmationPresented: Bool = false
    
    // NoCanvasView
    func handlePickedFullBodyPhoto(in context: ModelContext) {
        guard let item = photosPickerItem else { return }
        isProcessingPhoto = true

        Task {
            defer {
                isProcessingPhoto = false
                photosPickerItem = nil
            }

            guard let data = try? await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                return
            }

            do {
                let processedImage = try await backgroundRemovalService.removeBackground(from: uiImage)

                guard let photoData = processedImage.pngData() else { return }
                // pngData() penting (bukan jpegData) — PNG mendukung transparansi,
                // dan hasil remove background itu justru intinya transparan!

                // Cari profil yang sudah ada (Read manual, tanpa @Query)
                let descriptor = FetchDescriptor<UserFullBodyImageModel>()
                let existingProfile = try? context.fetch(descriptor).first

                if let profile = existingProfile {
                    profile.fullBodyPicData = photoData      // update — reference type!
                } else {
                    let newProfile = UserFullBodyImageModel(fullBodyPicData: photoData)
                    context.insert(newProfile)
                }

                let newCanvas = CanvasDataModel(name: "Untitled")
                context.insert(newCanvas)
                activeCanvas = newCanvas
            } catch {
                print("⚠️ Background removal gagal: \(error)")
            }
        }
    }
    
    // CanvasView
    // Delete
    // MARK: - Delete
    func requestDelete(_ canvas: CanvasDataModel) {
        canvasToDelete = canvas
        isDeleteConfirmationPresented = true
    }

    func confirmDelete(in context: ModelContext) {
        guard let canvas = canvasToDelete else { return }
        context.delete(canvas)
        // Tidak wajib context.save() manual — SwiftData autosave. Tapi kalau
        // mau eksplisit/defensif boleh ditambah try? context.save().
        canvasToDelete = nil
        isDeleteConfirmationPresented = false
    }

    // Rename
    func beginRename(_ canvas: CanvasDataModel) {
        canvasToRename = canvas
        renameText = canvas.name
        isRenamePresented = true
    }

    func commitRename() {
        // TODO (Anda isi):
        // - ambil canvasToRename (hati-hati optional)
        // - validasi renameText tidak kosong (trim spasi dulu)
        // - set canvas.name = hasil trim
        // - jangan lupa: canvas ini "diedit" — apa yang harus dipanggil? (ingat touch()!)
        // - tutup alert (isRenamePresented = false)
        
        // guard: pastikan ada canvas yang sedang di-rename
            guard let canvas = canvasToRename else { return }

            // trim spasi/newline di ujung, lalu tolak kalau jadi kosong
            let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                isRenamePresented = false
                return
            }

            canvas.name = trimmed
            canvas.updateLastUpdated()              // update lastUpdated — ini "edit"
            isRenamePresented = false
            canvasToRename = nil
    }
    
    
    func openCanvas(_ canvas: CanvasDataModel) {
        // Reset dulu gambar sisa dari canvas sebelumnya, supaya canvas lama
        // yang dibuka tidak "meminjam" foto milik canvas lain.
        activeCanvasBodyImage = nil
        activeCanvas = canvas
    }
}

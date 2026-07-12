//
//  LibraryViewModel.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 10/07/26.
//

//  State & logic layar library: filter gender, MULTI-seleksi item,
//  dan alur upload My Outfits (foto -> remove background -> simpan global).
//

import SwiftUI
import SwiftData
import PhotosUI

@Observable
final class LibraryViewModel {

    // MARK: - Gender filter

    var selectedGender: GenderCategory = .man

    /// Koleksi bawaan sesuai gender terpilih — filter bekerja sungguhan
    /// karena katalog sudah terbagi per gender.
    var sections: [ClothingSection] {
        BundledOutfitCatalog.sections(for: selectedGender)
    }

    // MARK: - Multi-selection

    /// Set, bukan single item — requirement: pilih 1 ATAU LEBIH.
    var selectedItems: Set<ClothingItem> = []

    var hasSelection: Bool { !selectedItems.isEmpty }

    func toggleSelection(_ item: ClothingItem) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }
    
    /// Mode add-clothes: item yang sudah ada di canvas masuk sebagai
    /// seleksi awal (bisa di-toggle). Guard selectedItems.isEmpty supaya
    /// tidak mereset seleksi kalau view re-render.
    func initializeSelection(preselectedIDs: Set<String>, userOutfits: [UserOutfitModel]) {
        guard !preselectedIDs.isEmpty, selectedItems.isEmpty else { return }

        let allBundled = (BundledOutfitCatalog.manSections + BundledOutfitCatalog.womanSections)
            .flatMap(\.items)
        let allUser = clothingItems(from: userOutfits)

        for item in allBundled + allUser where preselectedIDs.contains(item.id) {
            selectedItems.insert(item)
        }
    }

    func isSelected(_ item: ClothingItem) -> Bool {
        selectedItems.contains(item)
    }

    // MARK: - My Outfits (upload user, global untuk semua canvas)

    var photosPickerItem: PhotosPickerItem?
    var isProcessingUpload = false

    private let backgroundRemovalService = BackgroundRemovalService()

    /// Konversi record SwiftData -> item grid. Dipanggil dari View yang
    /// punya @Query-nya (ingat: @Query wajib tinggal di View).
    func clothingItems(from outfits: [UserOutfitModel]) -> [ClothingItem] {
        outfits.compactMap { outfit in
            guard let data = outfit.imageData else { return nil }
            return ClothingItem(
                name: "My Outfit",
                source: .userUpload(id: outfit.id, imageData: data)
            )
        }
    }

    func handlePickedOutfitPhoto(in context: ModelContext) {
        guard let item = photosPickerItem else { return }
        isProcessingUpload = true

        Task {
            defer { photosPickerItem = nil }

            guard let data = try? await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                isProcessingUpload = false
                return
            }
            await processOutfitImage(uiImage, in: context)
        }
    }

    func handleCapturedOutfitPhoto(_ image: UIImage?, in context: ModelContext) {
        guard let image else { return }
        isProcessingUpload = true

        Task {
            await processOutfitImage(image, in: context)
        }
    }

    private func processOutfitImage(_ uiImage: UIImage, in context: ModelContext) async {
        defer { isProcessingUpload = false }

        do {
            let processed = try await backgroundRemovalService.removeBackground(from: uiImage)
            guard let photoData = processed.pngData() else { return }
            context.insert(UserOutfitModel(imageData: photoData))
        } catch {
            print("⚠️ Background removal outfit gagal: \(error)")
        }
    }
}

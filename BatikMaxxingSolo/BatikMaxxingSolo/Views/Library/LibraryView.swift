//
//  LibraryView.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 10/07/26.
//

//  Layar pemilihan pakaian. Reusable dua mode lewat closure & parameter:
//  - Mode create-canvas: preselectedItemIDs kosong; onConfirm = buat
//    canvas baru dari foto titipan + pilihan.
//  - Mode add-clothes: preselectedItemIDs berisi item yang sudah ada di
//    canvas (masuk sebagai seleksi awal, bisa di-unselect); onConfirm =
//    daftar FINAL pilihan canvas (yang hilang dari daftar akan dihapus).
//  View ini tidak tahu mode apa — pemanggil yang menentukan maknanya.
//

import SwiftUI
import SwiftData
import PhotosUI

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = LibraryViewModel()

    /// Dipanggil saat user tap ✓ dengan >= 1 item terpilih.
    let onConfirm: (Set<ClothingItem>) -> Void

    /// Item yang sudah ada di canvas (mode add-clothes) — masuk sebagai
    /// seleksi awal, tetap bisa di-toggle. Default kosong = mode create.
    var preselectedItemIDs: Set<String> = []

    // Upload user untuk section "My Outfits" — reaktif, langsung muncul
    // begitu upload baru tersimpan.
    @Query(sort: \UserOutfitModel.createdAt, order: .reverse)
    private var userOutfits: [UserOutfitModel]

    // Presentation state (UI-lokal)
    @State private var isMyOutfitsExpanded = true
    @State private var expandedSectionIDs: Set<String> = []
    @State private var isPhotosPickerPresented = false
    @State private var isCameraPresented = false

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.96, blue: 0.96)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                LibraryNavBar(
                    isSelected: viewModel.hasSelection,
                    onBack: { dismiss() },
                    onSelect: {
                        guard viewModel.hasSelection else { return }
                        onConfirm(viewModel.selectedItems)
                    }
                )

                GenderPicker(selectedGender: $viewModel.selectedGender)

                ScrollView {
                    VStack(spacing: 14) {
                        LibrarySectionCard(
                            title: "My Outfits",
                            isExpanded: isMyOutfitsExpanded,
                            onTap: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    isMyOutfitsExpanded.toggle()
                                }
                            }
                        ) {
                            MyOutfitsGridContent(
                                outfits: viewModel.clothingItems(from: userOutfits),
                                isProcessingUpload: viewModel.isProcessingUpload,
                                isItemSelected: { viewModel.isSelected($0) },
                                onItemTapped: { viewModel.toggleSelection($0) },
                                onTakePhoto: { isCameraPresented = true },
                                onChoosePhoto: { isPhotosPickerPresented = true }
                            )
                        }

                        ForEach(viewModel.sections) { section in
                            LibrarySectionCard(
                                title: section.title,
                                hasAsset: section.hasDecorativeAsset,
                                isExpanded: expandedSectionIDs.contains(section.id),
                                onTap: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        if expandedSectionIDs.contains(section.id) {
                                            expandedSectionIDs.remove(section.id)
                                        } else {
                                            expandedSectionIDs.insert(section.id)
                                        }
                                    }
                                }
                            ) {
                                CategoryGridContent(
                                    items: section.items,
                                    isItemSelected: { viewModel.isSelected($0) },
                                    onItemTapped: { viewModel.toggleSelection($0) }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .photosPicker(
            isPresented: $isPhotosPickerPresented,
            selection: $viewModel.photosPickerItem,
            matching: .images
        )
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraPickerView { image in
                isCameraPresented = false
                viewModel.handleCapturedOutfitPhoto(image, in: modelContext)
            }
            .ignoresSafeArea()
        }
        .onChange(of: viewModel.photosPickerItem) { _, _ in
            viewModel.handlePickedOutfitPhoto(in: modelContext)
        }
        .onAppear {
            viewModel.initializeSelection(preselectedIDs: preselectedItemIDs, userOutfits: userOutfits)
        }
    }
}

#Preview("Mode create") {
    NavigationStack {
        LibraryView(onConfirm: { _ in })
    }
    .modelContainer(for: [
        CanvasDataModel.self,
        CanvasItemModel.self,
        UserFullBodyImageModel.self,
        UserOutfitModel.self
    ], inMemory: true)
}

#Preview("Mode add-clothes (preselected)") {
    NavigationStack {
        LibraryView(
            onConfirm: { _ in },
            preselectedItemIDs: ["ClothingItems/blue-parang-batik-shirt"]
        )
    }
    .modelContainer(for: [
        CanvasDataModel.self,
        CanvasItemModel.self,
        UserFullBodyImageModel.self,
        UserOutfitModel.self
    ], inMemory: true)
}

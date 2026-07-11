//
//  CanvasGrid.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 09/07/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct CanvasGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: CanvasGridViewModel
    @Bindable var noCanvasViewModel: NoCanvasViewModel
    let canvases: [CanvasDataModel]
    let onCanvasTapped: (CanvasDataModel) -> Void

    // Foto profil terakhir — untuk preview di sheet konfirmasi.
    @Query private var profiles: [UserFullBodyImageModel]

    @State private var isConfirmationSheetPresented = false
    @State private var isPhotosPickerPresented = false
    @State private var isCameraPresented = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var filteredCanvases: [CanvasDataModel] {
        viewModel.filteredCanvases(from: canvases)
    }

    private var latestProfileImage: UIImage? {
        guard let data = profiles.first?.fullBodyPicData else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredCanvases) { canvas in
                        Button {
                            onCanvasTapped(canvas)
                        } label: {
                            CanvasCardView(canvas: canvas)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button {
                                viewModel.beginRename(canvas)
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }

                            ShareLink(item: canvas.name) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }

                            Button(role: .destructive) {
                                viewModel.requestDelete(canvas)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 80)
            }

            bottomBar
        }
        .sheet(isPresented: $isConfirmationSheetPresented) {
            NewCanvasConfirmationSheet(
                previewImage: latestProfileImage,
                onProceed: {
                    isConfirmationSheetPresented = false
                    noCanvasViewModel.proceedWithExistingPhoto(in: modelContext) { newCanvas in
                        onCanvasTapped(newCanvas)
                    }
                },
                onRetakePhoto: {
                    isConfirmationSheetPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isCameraPresented = true
                    }
                },
                onChoosePhoto: {
                    isConfirmationSheetPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isPhotosPickerPresented = true
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .photosPicker(
            isPresented: $isPhotosPickerPresented,
            selection: $noCanvasViewModel.photosPickerItem,
            matching: .images
        )
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraPickerView { image in
                isCameraPresented = false
                noCanvasViewModel.handleCapturedFullBodyPhoto(image, in: modelContext) { newCanvas in
                    onCanvasTapped(newCanvas)
                }
            }
            .ignoresSafeArea()
        }
        .onChange(of: noCanvasViewModel.photosPickerItem) { _, _ in
            noCanvasViewModel.handlePickedFullBodyPhoto(in: modelContext) { newCanvas in
                onCanvasTapped(newCanvas)
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search", text: $viewModel.searchText)
                    .autocorrectionDisabled()

                Image(systemName: "mic")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(Capsule())

            Button {
                isConfirmationSheetPresented = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.black)
                    .frame(width: 48, height: 48)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

#Preview {
    CanvasGridView(
        viewModel: CanvasGridViewModel(),
        noCanvasViewModel: NoCanvasViewModel(),
        canvases: [
            CanvasDataModel(name: "Outfit Kantor"),
            CanvasDataModel(name: "Kondangan")
        ],
        onCanvasTapped: { _ in }
    )
    .modelContainer(for: [CanvasDataModel.self, UserFullBodyImageModel.self], inMemory: true)
}

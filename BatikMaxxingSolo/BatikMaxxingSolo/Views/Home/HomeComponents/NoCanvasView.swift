//
//  NoCanvasView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 09/07/26.
//

//  Layar kondisi belum ada canvas. State presentation (sheet, picker,
//  camera) sengaja di View karena murni UI-lokal; logic foto ada di
//  NoCanvasViewModel. onPhotoReady dipanggil saat foto badan selesai
//  diproses & dititip — pemanggil (HomeView) yang menavigasi ke library.
//

import SwiftUI
import PhotosUI
import SwiftData

struct NoCanvasView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: NoCanvasViewModel
    let onPhotoReady: () -> Void

    @State private var isSheetPresented = false
    @State private var isPhotosPickerPresented = false
    @State private var isCameraPresented = false

    var body: some View {
        VStack {
            Spacer()
            emptyStateContent
            Spacer()
            getStartedButton

            if viewModel.isProcessingPhoto {
                ProgressView("Removing background...")
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $isSheetPresented) {
            FrameYourLookSheetView(
                onTakePhoto: {
                    isSheetPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isCameraPresented = true
                    }
                },
                onChoosePhoto: {
                    isSheetPresented = false
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
            selection: $viewModel.photosPickerItem,
            matching: .images
        )
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraPickerView { image in
                isCameraPresented = false
                viewModel.handleCapturedFullBodyPhoto(image, in: modelContext, onPhotoReady: onPhotoReady)
            }
            .ignoresSafeArea()
        }
        .onChange(of: viewModel.photosPickerItem) { _, _ in
            viewModel.handlePickedFullBodyPhoto(in: modelContext, onPhotoReady: onPhotoReady)
        }
    }

    // MARK: - Subviews

    private var emptyStateContent: some View {
        VStack(spacing: 12) {
            // TODO: ganti dengan Image("EmptyStateIllustration") saat asset tersedia
            Image("ClothesFolded")
                .font(.system(size: 80))
                .foregroundStyle(.orange)

            Text("Clothes still folded up?")
                .font(.title3.bold())

            Text("Tap the button to start building your perfect fit!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
    }

    private var getStartedButton: some View {
        Button {
            isSheetPresented = true
        } label: {
            Text("Get Started")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.orange)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}

#Preview {
    NoCanvasView(viewModel: NoCanvasViewModel(), onPhotoReady: { })
        .modelContainer(for: [
            CanvasDataModel.self,
            CanvasItemModel.self,
            UserFullBodyImageModel.self,
            UserOutfitModel.self
        ], inMemory: true)
}

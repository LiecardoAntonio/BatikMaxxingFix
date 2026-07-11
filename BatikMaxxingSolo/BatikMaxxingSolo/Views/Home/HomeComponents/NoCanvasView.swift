//
//  NoCanvasView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 09/07/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct NoCanvasView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: HomeViewModel

    @State private var isSheetPresented = false
    @State private var isPhotosPickerPresented = false

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
                    // Camera menyusul — belum diimplementasikan
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
        .onChange(of: viewModel.photosPickerItem) { _, _ in
            viewModel.handlePickedFullBodyPhoto(in: modelContext)
        }
    }

    // MARK: - Subviews

    private var emptyStateContent: some View {
        VStack(spacing: 12) {
            // TODO: ganti dengan Image("EmptyStateIllustration")
            // begitu asset dari desainer tersedia
            Image(systemName: "tshirt")
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
    NoCanvasView(viewModel: HomeViewModel())
        .modelContainer(for: [CanvasDataModel.self, UserFullBodyImageModel.self], inMemory: true)
}

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

    @State private var isPhotosPickerPresented = false

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            VStack {
                Image(systemName: "heart.fill")
                    .padding(10)
                    .foregroundColor(Color.orange)
                Text("To mix and match, do something")
            }

            Spacer()

            Menu {
                Button("Choose in gallery") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPhotosPickerPresented = true
                    }
                }
                Button("Open camera") {
                    print("Open camera")
                }
            } label: {
                Text("Take a full body picture")
            }
            .frame(maxWidth: 320)
            .padding(16)
            .foregroundColor(Color.white)
            .background(Color.orange)
            .cornerRadius(10)

            if viewModel.isProcessingPhoto {
                ProgressView("Removing background...")
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .photosPicker(
            isPresented: $isPhotosPickerPresented,
            selection: $viewModel.photosPickerItem,
            matching: .images
        )
        .onChange(of: viewModel.photosPickerItem) { _, _ in
            viewModel.handlePickedFullBodyPhoto(in: modelContext)
        }
    }
}

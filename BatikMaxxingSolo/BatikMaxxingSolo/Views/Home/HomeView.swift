//
//  HomeView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 09/07/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var canvasContext
    @Query(sort: \CanvasDataModel.lastUpdated, order: .reverse)
    private var canvases: [CanvasDataModel]

    @State private var homeViewModel = HomeViewModel()
    @State private var noCanvasViewModel = NoCanvasViewModel()
    @State private var gridViewModel = CanvasGridViewModel()

    var body: some View {
        NavigationStack(path: $homeViewModel.path) {
            ZStack {
                Color.white.ignoresSafeArea(edges: .all)

                VStack {
                    HStack {
                        Text("All Outfits")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    .padding(16)

                    if canvases.isEmpty {
                        NoCanvasView(
                            viewModel: noCanvasViewModel,
                            onPhotoReady: { homeViewModel.startClothingSelection() }
                        )
                    } else {
                        CanvasGridView(
                            viewModel: gridViewModel,
                            noCanvasViewModel: noCanvasViewModel,
                            canvases: canvases,
                            onCanvasTapped: { homeViewModel.openCanvas($0) },
                            onPhotoReady: { homeViewModel.startClothingSelection() }
                        )
                    }
                }
            }
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .librarySelection:
                    LibraryView(onConfirm: { selectedItems in
                        noCanvasViewModel.createCanvas(with: selectedItems, in: canvasContext) { newCanvas in
                            homeViewModel.completeCanvasCreation(newCanvas)
                        }
                    })

                case .canvas(let canvas):
                    CanvasView(canvas: canvas)
                }
            }
            .onChange(of: homeViewModel.path) { _, newPath in
                // Library hilang dari tumpukan tanpa canvas lahir
                // (user back) -> buang foto titipan. Batal total.
                if !newPath.contains(.librarySelection) {
                    noCanvasViewModel.cancelPendingSelection()
                }
            }
            .alert("Rename Canvas", isPresented: $gridViewModel.isRenamePresented) {
                TextField("Name", text: $gridViewModel.renameText)
                Button("Cancel", role: .cancel) { }
                Button("Save") { gridViewModel.commitRename() }
            }
            .alert("Delete this canvas?", isPresented: $gridViewModel.isDeleteConfirmationPresented) {
                Button("Delete", role: .destructive) {
                    gridViewModel.confirmDelete(in: canvasContext)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [
            CanvasDataModel.self,
            CanvasItemModel.self,
            UserFullBodyImageModel.self,
            UserOutfitModel.self
        ], inMemory: true)
}

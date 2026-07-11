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
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea(edges: .all)

                VStack {
                    HStack {
                        Text("Collection")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                            
                        Spacer()
                    }
                    .padding(16)

                    if canvases.isEmpty {
                        NoCanvasView(
                            viewModel: noCanvasViewModel,
                            onCanvasCreated: { homeViewModel.openCanvas($0) }
                        )
                    } else {
                        CanvasGridView(
                            viewModel: gridViewModel,
                            noCanvasViewModel: noCanvasViewModel,
                            canvases: canvases,
                            onCanvasTapped: { homeViewModel.openCanvas($0) }
                        )
                    }
                }
            }
            .navigationDestination(item: $homeViewModel.activeCanvas) { canvas in
                CanvasView(canvas: canvas)
            }
            .alert("Rename Canvas", isPresented: $gridViewModel.isRenamePresented) {
                TextField("Name", text: $gridViewModel.renameText)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    gridViewModel.commitRename()
                }
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
        .modelContainer(for: [CanvasDataModel.self, UserFullBodyImageModel.self], inMemory: true)
}

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
    @Query private var canvases: [CanvasDataModel]
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
            NavigationStack {
                ZStack {
                    Color.white.ignoresSafeArea(edges: .all)

                    VStack{
                        HStack {
                            Text("All Outfits")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Spacer()
                        }
                        .padding(16)

                        if canvases.isEmpty {
                            NoCanvasView(viewModel: viewModel)
                        } else {
                            CanvasGridView(viewModel: viewModel, canvases: canvases)
                        }
                    }
                }
                .navigationDestination(item: $viewModel.activeCanvas) { canvas in
                    CanvasView(canvas: canvas)
                }
                .alert("Rename Canvas", isPresented: $viewModel.isRenamePresented) {
                                TextField("Name", text: $viewModel.renameText)
                                Button("Cancel", role: .cancel) { }
                                Button("Save") {
                                    viewModel.commitRename()
                                }
                            }
                .alert("Delete this canvas?", isPresented: $viewModel.isDeleteConfirmationPresented) {
                    Button("Delete", role: .destructive) {
                        viewModel.confirmDelete(in: canvasContext)
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
}

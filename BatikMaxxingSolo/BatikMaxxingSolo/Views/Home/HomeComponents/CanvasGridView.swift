//
//  CanvasGrid.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 09/07/26.
//

import SwiftUI

import SwiftUI
import SwiftData

struct CanvasGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: HomeViewModel
    let canvases: [CanvasDataModel]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(canvases) { canvas in
                    Button {
                        viewModel.openCanvas(canvas)
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
        }
    }
}

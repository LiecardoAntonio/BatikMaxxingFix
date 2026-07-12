//
//  CanvasItemView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 12/07/26.
//

//  Satu item yang sudah ditempatkan di canvas. Tap = pilih; drag = geser
//  (kecuali terkunci). Live offset di @State; commit ke model hanya saat
//  gesture selesai — satu gesture, satu perubahan data.
//

import SwiftUI

struct CanvasItemView: View {
    let item: CanvasItemModel
    let isSelected: Bool
    let canvasSize: CGSize
    let onTap: () -> Void
    let onDragEnded: (CGSize) -> Void

    @State private var liveDrag: CGSize = .zero

    var body: some View {
        itemImage
            .frame(width: canvasSize.width * item.relativeWidth)
            .overlay {
                if isSelected {
                    Rectangle()
                        .stroke(Color.orange, lineWidth: 2)
                }
            }
            .position(
                x: canvasSize.width * item.positionX + liveDrag.width,
                y: canvasSize.height * item.positionY + liveDrag.height
            )
            .zIndex(Double(item.zIndex))
            .opacity(item.isHidden ? 0 : 1)
            .allowsHitTesting(!item.isHidden)
            .onTapGesture(perform: onTap)
            .gesture(dragGesture)
    }

    @ViewBuilder
    private var itemImage: some View {
        if let assetName = item.assetName {
            Image(assetName)
                .resizable()
                .scaledToFit()
        } else if let data = item.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard !item.isLocked else { return }
                liveDrag = value.translation
            }
            .onEnded { value in
                guard !item.isLocked else { return }
                liveDrag = .zero
                onDragEnded(value.translation)
            }
    }
}

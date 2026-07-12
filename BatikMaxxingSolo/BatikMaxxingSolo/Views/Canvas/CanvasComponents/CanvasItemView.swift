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
//  Item di canvas: tap = pilih; drag = geser; pinch = resize; dua jari
//  putar = rotate. Semua live state di View, commit ke model hanya di
//  akhir gesture — satu gesture, satu perubahan data (nanti = satu undo).
//

import SwiftUI

struct CanvasItemView: View {
    let item: CanvasItemModel
    let isSelected: Bool
    let canvasSize: CGSize
    let onTap: () -> Void
    let onDragEnded: (CGSize) -> Void
    let onResizeEnded: (CGFloat) -> Void
    let onRotateEnded: (Double) -> Void

    @State private var liveDrag: CGSize = .zero
    @State private var liveScale: CGFloat = 1.0
    @State private var liveRotation: Angle = .zero

    var body: some View {
        itemImage
            .frame(width: canvasSize.width * item.relativeWidth)
            .overlay {
                if isSelected {
                    Rectangle().stroke(Color.orange, lineWidth: 2)
                }
            }
            .scaleEffect(liveScale)
            .rotationEffect(Angle(degrees: item.rotationDegrees) + liveRotation)
            .position(
                x: canvasSize.width * item.positionX + liveDrag.width,
                y: canvasSize.height * item.positionY + liveDrag.height
            )
            .zIndex(Double(item.zIndex))
            .opacity(item.isHidden ? 0 : 1)
            .allowsHitTesting(!item.isHidden)
            .onTapGesture(perform: onTap)
            .gesture(dragGesture)
            .simultaneousGesture(resizeGesture)
            .simultaneousGesture(rotateGesture)
    }

    @ViewBuilder
    private var itemImage: some View {
        if let assetName = item.assetName {
            Image(assetName).resizable().scaledToFit()
        } else if let data = item.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage).resizable().scaledToFit()
        }
    }

    // MARK: - Gestures

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

    private var resizeGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                guard !item.isLocked else { return }
                liveScale = value
            }
            .onEnded { value in
                guard !item.isLocked else { return }
                liveScale = 1.0
                onResizeEnded(value)
            }
    }

    private var rotateGesture: some Gesture {
        RotationGesture()
            .onChanged { value in
                guard !item.isLocked else { return }
                liveRotation = value
            }
            .onEnded { value in
                guard !item.isLocked else { return }
                liveRotation = .zero
                onRotateEnded(value.degrees)
            }
    }
}

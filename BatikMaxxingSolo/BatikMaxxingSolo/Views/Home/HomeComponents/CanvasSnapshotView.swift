//
//  CanvasSnapshotView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 13/07/26.
//

//  Replika statis isi canvas (tanpa gesture/handle) khusus untuk
//  dirender jadi thumbnail via ImageRenderer.
//

import SwiftUI

struct CanvasSnapshotView: View {
    let items: [CanvasItemModel]
    let size: CGSize

    var body: some View {
        ZStack {
            Color.white

            ForEach(items) { item in
                snapshotImage(for: item)
                    .frame(width: size.width * item.relativeWidth)
                    .rotationEffect(Angle(degrees: item.rotationDegrees))
                    .position(
                        x: size.width * item.positionX,
                        y: size.height * item.positionY
                    )
                    .zIndex(Double(item.zIndex))
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }

    @ViewBuilder
    private func snapshotImage(for item: CanvasItemModel) -> some View {
        if let assetName = item.assetName, let ui = UIImage(named: assetName) {
            Image(uiImage: ui).resizable().scaledToFit()
        } else if let data = item.imageData, let ui = UIImage(data: data) {
            Image(uiImage: ui).resizable().scaledToFit()
        }
    }
}

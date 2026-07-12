//
//  CanvasTrayView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 12/07/26.
//

//  Tray horizontal berisi item pilihan canvas + tombol "+" untuk
//  menambah dari library. Dumb component. Proporsi mengikuti Figma.
//

import SwiftUI

struct CanvasTrayView: View {
    let items: [CanvasItemModel]
    let isItemSelected: (CanvasItemModel) -> Bool
    let onItemTapped: (CanvasItemModel) -> Void
    let onAddTapped: () -> Void

    private let cardSize: CGFloat = 140

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Button(action: onAddTapped) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.orange)
                    .clipShape(Circle())
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        trayCard(for: item)
                    }
                }
            }
        }
        .padding(16)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 32))
    }

    private func trayCard(for item: CanvasItemModel) -> some View {
        Button {
            onItemTapped(item)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isItemSelected(item) ? Color.orange.opacity(0.25) : Color.white)

                trayImage(for: item)
                    .padding(12)
            }
            .frame(width: cardSize, height: cardSize)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isItemSelected(item) ? Color.orange : Color(red: 0.9, green: 0.9, blue: 0.9),
                            lineWidth: isItemSelected(item) ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func trayImage(for item: CanvasItemModel) -> some View {
        if let assetName = item.assetName {
            Image(assetName).resizable().scaledToFit()
        } else if let data = item.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage).resizable().scaledToFit()
        }
    }
}

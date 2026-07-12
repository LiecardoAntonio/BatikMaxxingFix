//
//  CanvasTrayView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 12/07/26.
//

//  Tray horizontal berisi item pilihan canvas + tombol "+" untuk
//  menambah dari library. Dumb component.
//

import SwiftUI

struct CanvasTrayView: View {
    let items: [CanvasItemModel]
    let isItemSelected: (CanvasItemModel) -> Bool
    let onItemTapped: (CanvasItemModel) -> Void
    let onAddTapped: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        trayCard(for: item)
                    }
                }
                .padding(16)
            }
            .frame(height: 130)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))

            Button(action: onAddTapped) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.orange)
                    .clipShape(Circle())
            }
            .offset(x: -8, y: -14)
        }
    }

    private func trayCard(for item: CanvasItemModel) -> some View {
        Button {
            onItemTapped(item)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isItemSelected(item) ? Color.orange.opacity(0.2) : Color(red: 0.96, green: 0.96, blue: 0.96))

                trayImage(for: item)
                    .padding(8)
            }
            .frame(width: 96, height: 96)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isItemSelected(item) ? Color.orange : Color(red: 0.88, green: 0.88, blue: 0.88),
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

//
//  ClothingItemCard 2.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 11/07/26.
//

//  Kartu satu item pakaian di library. Bisa merender dua sumber:
//  asset bawaan (bundled) maupun upload user (imageData).
//

import SwiftUI

struct ClothingItemCard: View {
    let item: ClothingItem
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                if isSelected {
                    Color.orange.opacity(0.15)
                } else {
                    Color(red: 0.96, green: 0.96, blue: 0.96)
                }

                itemImage
            }
            .frame(width: 140, height: 140)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.orange.opacity(0.4) : Color(red: 0.88, green: 0.88, blue: 0.88),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color.orange.opacity(0.15) : Color.black.opacity(0.03),
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    /// Render sesuai sumber item; fallback ke icon kalau gambar tidak ketemu.
    @ViewBuilder
    private var itemImage: some View {
        switch item.source {
        case .bundled(let assetName):
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(12)
            } else {
                fallbackIcon
            }

        case .userUpload(_, let imageData):
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(12)
            } else {
                fallbackIcon
            }
        }
    }

    private var fallbackIcon: some View {
        Image(systemName: "shirt.fill")
            .font(.system(size: 40))
            .foregroundColor(.gray.opacity(0.4))
    }
}

#Preview {
    HStack {
        ClothingItemCard(
            item: ClothingItem(name: "Contoh", source: .bundled(assetName: "ClothingItems/blue-parang-batik-shirt")),
            isSelected: false,
            onSelect: {}
        )
        ClothingItemCard(
            item: ClothingItem(name: "Terpilih", source: .bundled(assetName: "tidak-ada")),
            isSelected: true,
            onSelect: {}
        )
    }
    .padding()
}

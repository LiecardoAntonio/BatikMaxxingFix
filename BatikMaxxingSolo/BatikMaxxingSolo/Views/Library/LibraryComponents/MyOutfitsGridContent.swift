//
//  MyOutfitsGridContent.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 11/07/26.
//

import SwiftUI

struct MyOutfitsGridContent: View {
    let outfits: [ClothingItem]
    let isProcessingUpload: Bool
    let isItemSelected: (ClothingItem) -> Bool
    let onItemTapped: (ClothingItem) -> Void
    let onTakePhoto: () -> Void
    let onChoosePhoto: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                addOutfitMenu

                ForEach(outfits) { outfit in
                    ClothingItemCard(
                        item: outfit,
                        isSelected: isItemSelected(outfit),
                        onSelect: { onItemTapped(outfit) }
                    )
                }
            }
        }
    }

    private var addOutfitMenu: some View {
        Menu {
            Button(action: onTakePhoto) {
                Label("Take Photo", systemImage: "camera")
            }
            Button(action: onChoosePhoto) {
                Label("Choose Photo", systemImage: "photo.on.rectangle")
            }
        } label: {
            ZStack {
                if isProcessingUpload {
                    ProgressView()
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.black)
                }
            }
            .frame(width: 140, height: 140)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
            )
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .disabled(isProcessingUpload)
    }
}

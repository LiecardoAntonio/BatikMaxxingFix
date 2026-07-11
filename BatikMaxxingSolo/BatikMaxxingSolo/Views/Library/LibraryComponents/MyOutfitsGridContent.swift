//
//  MyOutfitsGridContent.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 11/07/26.
//

import SwiftUI

// MARK: - Component: My Outfits Layout Grid Inner Content
struct MyOutfitsGridContent: View {
    // Pass in the dynamic list of user outfits
    let outfits: [ClothingItem]
    let selectedItemID: UUID?
    let onUniformSelection: (ClothingItem) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                // MARK: Add Asset Context Menu
                Menu {
                    Button(action: {
                        // Trigger your camera implementation
                        print("Take Photo tapped")
                    }) {
                        Label("Take Photo", systemImage: "camera")
                    }
                    
                    Button(action: {
                        // Trigger your photo library picker implementation
                        print("Choose Photo tapped")
                    }) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                    }
                } label: {
                    // Kept the visual button styling exactly the same as your layout design
                    VStack {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(.black)
                    }
                    .frame(width: 140, height: 140)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                    )
                }
                .menuStyle(BorderlessButtonMenuStyle()) // Avoids overriding visual styles
                
                // Dynamic Loop: Only renders cards if there are items in the array
                ForEach(outfits) { outfit in
                    let isSelected = selectedItemID == outfit.id
                    
                    Button(action: { onUniformSelection(outfit) }) {
                        ZStack {
                            // Enveloping background layer: shifts to soft orange tint when selected
                            if isSelected {
                                Color.orange.opacity(0.15)
                            } else {
                                Color(red: 0.96, green: 0.96, blue: 0.96)
                            }
                            
                            if UIImage(named: outfit.imageName) != nil {
                                Image(outfit.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                            } else {
                                Image(systemName: "shirt")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red.opacity(0.7))
                            }
                        }
                        .frame(width: 140, height: 140)
                        .cornerRadius(12)
                        // Outer matching frame stroke line
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
            }
        }
    }
}

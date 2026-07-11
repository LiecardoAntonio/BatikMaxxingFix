//
//  ClothingItemCard 2.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 11/07/26.
//
import SwiftUI

struct ClothingItemCard: View {
    let item: ClothingItem
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            ZStack {
                // Enveloping background change layer
                if isSelected {
                    Color.orange.opacity(0.15)
                } else {
                    Color(red: 0.96, green: 0.96, blue: 0.96)
                }
                
                if UIImage(named: item.imageName) != nil {
                    Image(item.imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                } else {
                    Image(systemName: "shirt.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.4))
                }
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
}

//
//  ClothingItemCard.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 11/07/26.
//

import SwiftUI

// MARK: - Component: Individual Clothing Card
struct ClothingItemCard: View {
    let item: ClothingItem
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Color(red: 0.96, green: 0.96, blue: 0.96)
                
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
            .frame(width: 140, height: 105) // Scaled wide to host original grid asset constraints nicely
            .cornerRadius(8)
            
            Text(item.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .lineLimit(1)
                .padding(.horizontal, 6)
        }
        .frame(width: 140, height: 140) // Anchored securely back to your original view size spec
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.88, green: 0.88, blue: 0.88), lineWidth: 1)
        )
    }
}

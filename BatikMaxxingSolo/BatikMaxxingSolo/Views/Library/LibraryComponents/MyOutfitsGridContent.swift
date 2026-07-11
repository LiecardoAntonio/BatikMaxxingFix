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
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                // Add Asset Button (Always shows up)
                Button(action: { /* Add Asset action */ }) {
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
                
                // Dynamic Loop: Only renders cards if there are items in the array
                ForEach(outfits) { outfit in
                    VStack(spacing: 8) {
                        ZStack {
                            Color(red: 0.96, green: 0.96, blue: 0.96)
                            
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
                        .frame(width: 140, height: 105)
                        .cornerRadius(8)
                        
                        Text(outfit.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .padding(.horizontal, 6)
                    }
                    .frame(width: 140, height: 140)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.88, green: 0.88, blue: 0.88), lineWidth: 1)
                    )
                }
            }
        }
    }
}

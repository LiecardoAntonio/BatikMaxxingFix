//
//  CategoryGridContent.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 11/07/26.
//

import SwiftUI

// MARK: - Component: Categories Grid Inner Content
struct CategoryGridContent: View {
    let items: [ClothingItem]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                // Add Action Card (Restored to wide proportions matching your original minHeight: 140 framework)
                Button(action: { /* Add Action */ }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.black)
                        .frame(width: 140, height: 140) // Restored original size aspect scaling layout bounds
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                        )
                }
                
                // Dynamic Items Iteration Loop
                ForEach(items) { item in
                    ClothingItemCard(item: item)
                }
            }
        }
    }
}

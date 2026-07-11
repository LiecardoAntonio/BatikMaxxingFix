//
//  CategoryGridContent.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 11/07/26.
//

import SwiftUI

struct CategoryGridContent: View {
    let items: [ClothingItem]
    let selectedItemID: UUID?
    let onUniformSelection: (ClothingItem) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                // Add Action Card
//                Button(action: { /* Add Action */ }) {
//                    Image(systemName: "plus")
//                        .font(.system(size: 24, weight: .light))
//                        .foregroundColor(.black)
//                        .frame(width: 140, height: 140)
//                        .background(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
//                        )
//                }
                
                // Dynamic Items
                ForEach(items) { item in
                    ClothingItemCard(
                        item: item,
                        isSelected: selectedItemID == item.id,
                        onSelect: { onUniformSelection(item) }
                    )
                }
            }
        }
    }
}

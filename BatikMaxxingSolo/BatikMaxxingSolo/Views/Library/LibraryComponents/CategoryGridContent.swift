//
//  CategoryGridContent.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 11/07/26.
//

import SwiftUI

struct CategoryGridContent: View {
    let items: [ClothingItem]
    let isItemSelected: (ClothingItem) -> Bool
    let onItemTapped: (ClothingItem) -> Void
    let onItemLongPressed: (ClothingItem) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(items) { item in
                    ClothingItemCard(
                        item: item,
                        isSelected: isItemSelected(item),
                        onSelect: { onItemTapped(item) },
                        onLongPress: { onItemLongPressed(item) }
                    )
                }
            }
        }
    }
}

//
//  LibraryNavBar.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 11/07/26.
//

import SwiftUI

// MARK: - Component: Navigation Bar
struct LibraryNavBar: View {
    let isSelected: Bool // Tracks if an asset is currently selected
    let onBack: () -> Void
    let onSelect: () -> Void
    
    var body: some View {
        ZStack {
            // Center Title Layer
            Text("Clothing Library")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.primary)
            
            // Interactive Buttons Layer
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .glassEffect()
                }
                
                Spacer()
                
                Button(action: onSelect) {
                    Group {
                        if isSelected {
                            // Custom solid orange container with an explicit clean white checkmark
                            ZStack {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        } else {
                            // Standard placeholder text when nothing is selected
                            Text("Select")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                        }
                    }
                    .frame(height: 44)
                    .glassEffect()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .frame(height: 56)
    }
}

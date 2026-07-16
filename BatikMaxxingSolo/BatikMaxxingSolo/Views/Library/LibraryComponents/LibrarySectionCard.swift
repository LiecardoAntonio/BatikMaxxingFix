//
//  LibrarySectionCard.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 11/07/26.
//

import SwiftUI

struct LibrarySectionCard<Content: View>: View {
    let title: String
    let hasAsset: Bool
    let isExpanded: Bool
    let onTap: () -> Void
    let content: Content
    
    init(
        title: String,
        hasAsset: Bool = false,
        isExpanded: Bool,
        onTap: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.hasAsset = hasAsset
        self.isExpanded = isExpanded
        self.onTap = onTap
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Unification Header Interactivity Area
            HStack {
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .foregroundColor(.gray)
                
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Decorative floral alignment assets
                if hasAsset {
                    Image("BatikPattern")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                        .opacity(isExpanded ? 0.3 : 1.0)
                }
            }
            .padding(.all, 24)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            
            // Conditional body asset insertion context
            if isExpanded {
                Divider()
                    .padding(.horizontal, 24)
                
                content
                    .padding(.all, 24)
            }
        }
        .background(Color.white) // Added explicit background fill card layer
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
        )
    }
}

//
//  LibraryView.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 10/07/26.
//

import SwiftUI

// MARK: - Library View
struct LibraryView: View {
    @State private var viewModel = LibraryViewModel()
    
    var body: some View {
        ZStack {
            // App background color matching the design
            Color(red: 0.96, green: 0.96, blue: 0.96)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: Navigation Bar
                ZStack {
                    // 1. Center Title Layer (Guarantees perfect center-alignment regardless of button sizes)
                    Text("Clothing Library")
                        .font(.system(size: 22, weight: .semibold)) // Matches the prominent typography in your design
                        .foregroundColor(.primary)
                    
                    // 2. Interactive Buttons Layer
                    HStack {
                        // Liquid Glass Back Button
                        Button(action: { /* Back Action */ }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .glassEffect()
                                // Swap with your custom modifier if needed: .glassEffect()
                        }
                        
                        Spacer()
                        
                        // Liquid Glass Select Button
                        Button(action: { /* Select Action */ }) {
                            Text("Select")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .frame(height: 44) // Locks height to match back button, lets width adapt to text
                                .glassEffect()
                                // Swap with your custom modifier if needed: .glassEffect()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .frame(height: 56) // Standard native navigation bar height for layout consistency
                
                // MARK: Segmented Control
                Picker("Gender", selection: $viewModel.selectedGender){
                    ForEach(GenderCategory.allCases) { category in
                        Text(category.rawValue.capitalized).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                
                // MARK: Accordion List Canvas
                ScrollView {
                    VStack(spacing: 14) {
                        
                        // "My Outfits" Section (Hardcoded open state example)
                        MyOutfitsSection()
                        
                        // Dynamic Accordion Sections
                        ForEach(viewModel.sections) { section in
                            LibraryAccordionCard(
                                title: section.title,
                                hasAsset: section.hasDecorativeAsset,
                                isExpanded: viewModel.expandedSectionID == section.id,
                                onTap: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        if viewModel.expandedSectionID == section.id {
                                            viewModel.expandedSectionID = nil
                                        } else {
                                            viewModel.expandedSectionID = section.id
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

// MARK: - My Outfits Section View
struct MyOutfitsSection: View {
    @State private var isOpen: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isOpen ? 90 : 0))
                    .foregroundColor(.gray)
                Text("My Outfits")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.all, 20)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isOpen.toggle()
                }
            }
            
            if isOpen {
                Divider()
                    .padding(.horizontal, 20)
                
                // Asset grid container
                HStack(spacing: 14) {
                    // Add Button Inside Box
                    Button(action: { /* Add Asset action */ }) {
                        VStack {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, minHeight: 140)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                        )
                    }
                    
                    // Spawned Asset Grid Box (Example Item)
                    VStack {
                        // Replace with image asset when ready
                        Image(systemName: "shirt")
                            .font(.system(size: 40))
                            .foregroundColor(.red.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, minHeight: 140)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                    )
                    
                    Spacer()
                }
                .padding(.all, 20)
            }
        }
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
        )
    }
}

// MARK: - Accordion Card View Component
struct LibraryAccordionCard: View {
    let title: String
    let hasAsset: Bool
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .foregroundColor(.gray)
                
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Decorative flower pattern alignment simulation
                if hasAsset {
                    HStack(spacing: -4) {
                        Image(systemName: "laurel.leading")
                            .font(.title2)
                        Image(systemName: "flame.fill")
                            .font(.title3)
                    }
                    .foregroundColor(.orange.opacity(0.6))
                    .opacity(isExpanded ? 0.3 : 1.0)
                }
            }
            .padding(.all, 24)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            
            if isExpanded {
                Divider()
                    .padding(.horizontal, 24)
                
                // Asset grid container shown upon expansion
                HStack(spacing: 14) {
                    Button(action: { /* Add Action */ }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                            .frame(width: 100, height: 110)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                            )
                    }
                    Spacer()
                }
                .padding(.all, 24)
            }
        }
        // State switching color animation framework (#E6A63C80 configuration when true)
        .background(isExpanded ? Color(hex: "E6A63C").opacity(0.5) : Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
        )
    }
}

// MARK: - Hex Color Extension Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

// MARK: - Preview
struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}

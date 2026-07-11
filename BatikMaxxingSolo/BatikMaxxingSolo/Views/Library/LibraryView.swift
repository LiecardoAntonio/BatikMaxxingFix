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
    @State private var isMyOutfitsExpanded: Bool = true
    
    var body: some View {
        ZStack {
            // App background color matching the design
            Color(red: 0.96, green: 0.96, blue: 0.96)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: Navigation Bar
                LibraryNavBar(
                    onBack: { /* Back Action */ },
                    onSelect: { /* Select Action */ }
                )
                
                // MARK: Segmented Control
                GenderPicker(selectedGender: $viewModel.selectedGender)
                
                // MARK: Accordion List Canvas
                ScrollView {
                    VStack(spacing: 14) {
                        
                        // Using the external LibrarySectionCard component for "My Outfits"
                        // Inside LibraryView body:
                        LibrarySectionCard(
                            title: "My Outfits",
                            isExpanded: isMyOutfitsExpanded,
                            onTap: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    isMyOutfitsExpanded.toggle()
                                }
                            }
                        ) {
                            
                            MyOutfitsGridContent(outfits: viewModel.myOutfits)
                        }
                        
                        // Using the external LibrarySectionCard component for Dynamic Categories
                        ForEach(viewModel.sections) { section in
                            LibrarySectionCard(
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
                            ) {
                                CategoryGridContent(items: section.items)
                            }
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

// MARK: - Preview
struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}

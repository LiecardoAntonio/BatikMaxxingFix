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
    
    // Selection and Routing States
    @State private var selectedItem: ClothingItem? = nil
    @State private var navigateToNextPage = false
    @State private var expandedSectionIDs: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                // App background color matching the design
                Color(red: 0.96, green: 0.96, blue: 0.96)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: Navigation Bar
                    LibraryNavBar(
                        isSelected: selectedItem != nil, // Dynamic state pass-through
                        onBack: { /* Back Action */ },
                        onSelect: {
                            // Only trigger navigation if an item has been selected
                            if selectedItem != nil {
                                navigateToNextPage = true
                            }
                        }
                    )
                    
                    // MARK: Segmented Control
                    GenderPicker(selectedGender: $viewModel.selectedGender)
                    
                    // MARK: Accordion List Canvas
                    ScrollView {
                        VStack(spacing: 14) {
                            
                            // Using the external LibrarySectionCard component for "My Outfits"
                            LibrarySectionCard(
                                title: "My Outfits",
                                isExpanded: isMyOutfitsExpanded,
                                onTap: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        isMyOutfitsExpanded.toggle()
                                    }
                                }
                            ) {
                                MyOutfitsGridContent(
                                    outfits: viewModel.myOutfits,
                                    selectedItemID: selectedItem?.id,
                                    onUniformSelection: { clickedItem in
                                        handleSelection(clickedItem)
                                    }
                                )
                            }
                            
                            // Using the external LibrarySectionCard component for Dynamic Categories
                            ForEach(viewModel.sections) { section in
                                LibrarySectionCard(
                                    title: section.title,
                                    hasAsset: section.hasDecorativeAsset,
                                    isExpanded: expandedSectionIDs.contains(section.id), // Tracks independent open state
                                    onTap: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            if expandedSectionIDs.contains(section.id) {
                                                expandedSectionIDs.remove(section.id) // Closes clicked item
                                            } else {
                                                expandedSectionIDs.insert(section.id) // Appends to open collection list
                                            }
                                        }
                                    }
                                ) {
                                    CategoryGridContent(
                                        items: section.items,
                                        selectedItemID: selectedItem?.id,
                                        onUniformSelection: { clickedItem in
                                            handleSelection(clickedItem)
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                    }
                }
            }
            // MARK: Navigation Destination Routing Layer
            .navigationDestination(isPresented: $navigateToNextPage) {
                if let itemToSend = selectedItem {
                    // Replace DetailView with your actual next target View screen file
                    DetailView(item: itemToSend)
                }
            }
        }
    }
    
    // Core selection toggle helper logic
    private func handleSelection(_ clickedItem: ClothingItem) {
        if selectedItem?.id == clickedItem.id {
            selectedItem = nil // Deselect if tapped again
        } else {
            selectedItem = clickedItem // Apply new selection target
        }
    }
}

// MARK: - Dummy Destination View Example
struct DetailView: View {
    let item: ClothingItem
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Selected Wardrobe Item")
                .font(.title2)
                .bold()
            
            if UIImage(named: item.imageName) != nil {
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                Image(systemName: "shirt.fill")
                    .font(.system(size: 60))
            }
            
            Text(item.name)
                .font(.headline)
        }
    }
}

// MARK: - Preview
struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}

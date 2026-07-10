//
//  LibraryViewModel.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 10/07/26.
//

import SwiftUI
import Observation

@Observable
final class LibraryViewModel {
    // MARK: - State Properties
    var selectedGender: GenderCategory = .man
    var expandedSectionID: UUID? = nil
    
    // Sample categories based on your Figma design
    var sections: [ClothingSection] = [
        ClothingSection(title: "Batik Shirts", hasDecorativeAsset: true),
        ClothingSection(title: "Batik Pants", hasDecorativeAsset: true),
        ClothingSection(title: "Outerwear", hasDecorativeAsset: false),
        ClothingSection(title: "Casual Pants", hasDecorativeAsset: false)
    ]
    
    // MARK: - Intent Methods
    func toggleSection(_ sectionID: UUID) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            if expandedSectionID == sectionID {
                expandedSectionID = nil
            } else {
                expandedSectionID = sectionID
            }
        }
    }
    
    func handleBackAction() {
        // Handle your navigation back here
    }
    
    func handleSelectAction() {
        // Handle selection state flow
    }
}

//
//  LibraryModel.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 10/07/26.
//

import Foundation

// MARK: - Models & Mock Data
enum GenderCategory: String, CaseIterable, Identifiable {
    case man = "Man"
    case woman = "Woman"
    
    var id: String { self.rawValue }
}

struct ClothingSection: Identifiable {
    let id = UUID()
    let title: String
    let hasDecorativeAsset: Bool
}

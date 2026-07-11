//
//  GenderPicker.swift
//  BatikMaxxingSolo
//
//  Created by James Richard Renaldo on 11/07/26.
//

import SwiftUI

// MARK: - Component: Gender Picker Control
struct GenderPicker: View {
    @Binding var selectedGender: GenderCategory
    
    var body: some View {
        Picker("Gender", selection: $selectedGender) {
            ForEach(GenderCategory.allCases) { category in
                Text(category.rawValue.capitalized).tag(category)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
}

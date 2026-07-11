//
//  HomeViewModel.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 09/07/26.
//

import SwiftUI
import Observation

@Observable
final class HomeViewModel {

    /// Sinyal navigasi: begitu terisi, HomeView push ke CanvasView
    /// (lihat .navigationDestination(item:) di HomeView).
    var activeCanvas: CanvasDataModel?

    func openCanvas(_ canvas: CanvasDataModel) {
        activeCanvas = canvas
    }
}

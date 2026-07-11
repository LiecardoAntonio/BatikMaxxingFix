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

    /// Tumpukan navigasi. Kosong = di Home.
    var path: [HomeRoute] = []

    /// Tap card canvas lama → langsung ke canvas.
    func openCanvas(_ canvas: CanvasDataModel) {
        path.append(.canvas(canvas))
    }

    /// Foto badan siap → lanjut pilih baju.
    func startClothingSelection() {
        path.append(.librarySelection)
    }

    /// Canvas baru lahir dari library → GANTI seluruh tumpukan jadi
    /// [canvas] saja: library lenyap dari sejarah, back dari canvas
    /// langsung ke Home.
    func completeCanvasCreation(_ canvas: CanvasDataModel) {
        path = [.canvas(canvas)]
    }
}

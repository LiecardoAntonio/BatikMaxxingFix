//
//  BatikMaxxingSoloApp.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 09/07/26.
//

import SwiftUI
import SwiftData

@main
struct BatikMaxxingSoloApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer( // this will serve as the container to store the data so it will be persistent
            for: [
                CanvasDataModel.self,
                CanvasItemModel.self,
                UserFullBodyImageModel.self,
                UserOutfitModel.self
            ],
            isUndoEnabled: true // so we can undo/redo
        )
    }
}

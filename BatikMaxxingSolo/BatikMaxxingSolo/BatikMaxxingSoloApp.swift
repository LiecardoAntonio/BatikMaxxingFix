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
        .modelContainer(for: [CanvasDataModel.self, UserFullBodyImageModel.self]) // this will serve as the container to store the data so it will be persistent
    }
}

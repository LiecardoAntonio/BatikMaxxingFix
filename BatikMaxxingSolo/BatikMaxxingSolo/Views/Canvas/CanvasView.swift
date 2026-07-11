//
//  CanvasView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 10/07/26.
//

import SwiftUI
import SwiftData

struct CanvasView: View {
    let canvas: CanvasDataModel

    private var bodyImage: UIImage? {
        guard let data = canvas.fullBodyPicData else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        VStack {
            Text(canvas.name).font(.headline)

            if let bodyImage {
                Image(uiImage: bodyImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Belum ada foto badan")
            }
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        CanvasView(canvas: CanvasDataModel(name: "Preview Canvas"))
    }
    .modelContainer(for: [CanvasDataModel.self, UserFullBodyImageModel.self], inMemory: true)
}

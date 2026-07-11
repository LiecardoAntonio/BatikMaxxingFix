//
//  CanvasView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 10/07/26.
//

import SwiftUI

struct CanvasView: View {
    let canvas: CanvasDataModel
    let bodyImage: UIImage?

    var body: some View {
        VStack {
            Text(canvas.name)
                .font(.headline)

            if let bodyImage {
                Image(uiImage: bodyImage)
                    .resizable()
                    .scaledToFit()
                    .background(Color.gray.opacity(0.3))
            } else {
                Text("Tidak ada foto")
            }
        }
        .padding()
    }
}

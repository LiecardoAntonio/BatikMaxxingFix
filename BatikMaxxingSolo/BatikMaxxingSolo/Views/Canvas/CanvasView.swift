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
    @Query private var profiles: [UserFullBodyImageModel]

    private var bodyImage: UIImage? {
        guard let data = profiles.first?.fullBodyPicData else { return nil }
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

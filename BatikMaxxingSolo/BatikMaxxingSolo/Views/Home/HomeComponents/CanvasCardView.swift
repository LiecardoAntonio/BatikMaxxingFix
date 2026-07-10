//
//  CanvasCardView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 10/07/26.
//

import SwiftUI

import SwiftUI

struct CanvasCardView: View {
    let canvas: CanvasDataModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // --- Thumbnail area (atas) ---
            thumbnail
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .background(Color.white)

            // --- Info area (bawah) ---
            VStack(alignment: .leading, spacing: 2) {
                Text(canvas.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)

                Text(canvas.lastUpdated, format: .dateTime.day().month().year().hour().minute())
                    .font(.system(size: 12))
                    .foregroundStyle(.black.opacity(0.6))
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.6))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
        )
        
    }

    @ViewBuilder
    private var thumbnail: some View {
        // Data → UIImage → Image; kalau nil/gagal, tampilkan kotak kosong
        if let data = canvas.thumbnailPicData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .clipped()
        } else {
            Color.white
        }
    }
}

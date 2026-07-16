//
//  BatikInfoSheet.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 13/07/26.
//

//  Sheet informasi kultural sebuah motif batik. Dumb component.

import SwiftUI

struct BatikInfoSheet: View {
    let info: BatikInfo
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Text(info.title)
                    .font(.headline)

                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(width: 36, height: 36)
                            .glassEffect()
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            mapView

            Text(info.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            Spacer()
        }
    }

    /// Peta asal batik. Placeholder dipakai selama asset belum masuk ke
    /// Assets.xcassets, supaya tidak menampilkan kotak kosong.
    @ViewBuilder
    private var mapView: some View {
        if UIImage(named: info.mapAssetName) != nil {
            Image(info.mapAssetName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 180)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.94, green: 0.94, blue: 0.94))
                .frame(height: 180)
                .overlay {
                    VStack(spacing: 6) {
                        Image(systemName: "map")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        Text(info.originRegion)
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    BatikInfoSheet(
        info: BatikInfo(
            title: "Batik Parang",
            originRegion: "Yogyakarta",
            description: "Originally from Yogyakarta, Batik Parang is one of Indonesia's oldest batik motifs. The word parang comes from pereng, meaning \"sloping cliff,\" and symbolizes strength, resilience, perseverance, and an unwavering spirit in facing life's challenges.",
            mapAssetName: "BatikMaps/parang-map"
        ),
        onClose: {}
    )
}

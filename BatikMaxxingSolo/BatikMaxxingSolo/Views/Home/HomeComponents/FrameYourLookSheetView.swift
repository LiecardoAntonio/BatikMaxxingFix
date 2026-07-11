//
//  FrameYourLookSheet.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 11/07/26.
//

//  Komponen murni tampilan (dumb component) — tidak tahu aksi apapun,
//  hanya meneruskan lewat closure. Bisa dipakai ulang nanti untuk
//  fitur "ganti foto badan" dari CanvasView.
//

import SwiftUI

struct FrameYourLookSheetView: View {
    let onTakePhoto: () -> Void
    let onChoosePhoto: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Frame Your Look!")
                .font(.headline)
                .padding(.top, 20)

            illustration

            instruction

            Spacer()

            actionButtons
        }
    }

    // MARK: - Subviews

    private var illustration: some View {
        // TODO: ganti dengan Image("FrameYourLookIllustration")
        // begitu asset dari desainer masuk ke Assets.xcassets
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            .overlay(
                Image(systemName: "figure.stand")
                    .font(.system(size: 120))
                    .foregroundStyle(.black)
            )
            .frame(maxHeight: 400)
            .padding(.horizontal, 24)
    }

    private var instruction: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BEFORE YOU SNAP 📸")
                .font(.subheadline.bold())

            Text("To easily mix and match later, ensure your body is visible from head to toe. Prop your phone up or use a full-length mirror for the best capture.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: onTakePhoto) {
                Text("Take Photo")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }

            Button(action: onChoosePhoto) {
                Text("Choose Photo")
                    .font(.headline)
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule().stroke(Color.orange.opacity(0.4), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}


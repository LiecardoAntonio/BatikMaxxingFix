//
//  NewCanvasConfirmationSheet.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 11/07/26.
//

//  Sheet konfirmasi saat membuat canvas baru: preview foto badan terakhir,
//  user bisa proceed (pakai foto itu) atau retake/choose foto baru.
//  Dumb component — semua keputusan lewat closure.
//

import SwiftUI

struct NewCanvasConfirmationSheet: View {
    let previewImage: UIImage?
    let onProceed: () -> Void
    let onRetakePhoto: () -> Void
    let onChoosePhoto: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Text("Frame Your Look!")
                    .font(.headline)
                Spacer()
            }
            .overlay(alignment: .trailing) {
                Button(action: onProceed) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
            }
            .padding(.top, 20)

            photoPreview

            VStack(alignment: .leading, spacing: 8) {
                Text("LOOKS GOOD? ✨")
                    .font(.subheadline.bold())

                Text("If your full body photo is visible from head to toe, you're all set to continue. Need a better shot? Retake your photo for more accurate styling.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                secondaryButton("Retake Photo", action: onRetakePhoto)
                secondaryButton("Choose Photo", action: onChoosePhoto)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private var photoPreview: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            .overlay {
                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                } else {
                    Text("No photo yet")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxHeight: 400)
            .padding(.horizontal, 24)
    }

    private func secondaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                )
        }
    }
}

#Preview {
    NewCanvasConfirmationSheet(
        previewImage: nil,
        onProceed: {},
        onRetakePhoto: {},
        onChoosePhoto: {}
    )
}

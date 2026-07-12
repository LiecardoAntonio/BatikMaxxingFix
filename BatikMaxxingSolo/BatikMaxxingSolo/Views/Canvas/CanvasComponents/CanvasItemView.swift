//
//  CanvasItemView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 12/07/26.
//

//  Satu item yang sudah ditempatkan di canvas. Tap = pilih; drag = geser
//  (kecuali terkunci). Live offset di @State; commit ke model hanya saat
//  gesture selesai — satu gesture, satu perubahan data.
//
//  Item di canvas: tap = pilih; drag = geser; pinch = resize; dua jari
//  putar = rotate. Semua live state di View, commit ke model hanya di
//  akhir gesture — satu gesture, satu perubahan data (nanti = satu undo).
//
//  Catatan geometri penting:
//  1. Seluruh view dibungkus frame dengan MARGIN SIMETRIS di semua sisi
//     (ruang untuk handle). Simetris = titik tengah frame tetap sama
//     dengan titik tengah gambar, sehingga .position() dan .rotationEffect
//     (anchor .center) tetap presisi tanpa offset tambahan.
//  2. Handle visual kecil (24pt) tapi area sentuh 44pt (standar HIG) —
//     lewat frame transparan di sekelilingnya.
//  3. Resize: translation jari dilaporkan dalam ruang layar, padahal
//     handle ikut ter-rotate — jadi dikonversi ke ruang lokal item pakai
//     trigonometri sebelum dihitung jaraknya dari pusat.
//  4. Rotate: pakai DragGesture(coordinateSpace: .global) + posisi pusat
//     item yang dilacak GeometryReader di ruang .global — sudut dihitung
//     dengan atan2 dari pusat ke jari, tanpa aproksimasi.
//

import SwiftUI

struct CanvasItemView: View {
    let item: CanvasItemModel
    let isSelected: Bool
    let canvasSize: CGSize
    let onTap: () -> Void
    let onDragEnded: (CGSize) -> Void
    let onResizeEnded: (CGFloat) -> Void
    let onRotateEnded: (Double) -> Void

    // Live state — commit ke model hanya di akhir gesture
    @State private var liveDrag: CGSize = .zero
    @State private var liveScale: CGFloat = 1.0
    @State private var liveRotation: Angle = .zero

    // Snapshot untuk gesture handle
    @State private var rotationStartFingerAngle: Double?
    @State private var accumulatedRotationDelta: Double = 0
    @State private var itemCenterGlobal: CGPoint = .zero

    private let handleVisualSize: CGFloat = 24
    private let handleTouchSize: CGFloat = 44
    private let rotateHandleDistance: CGFloat = 40

    private var margin: CGFloat { rotateHandleDistance + handleTouchSize }

    /// Aspect ratio gambar (width/height) — untuk menghitung tinggi render.
    private var imageAspect: CGFloat {
        if let assetName = item.assetName, let ui = UIImage(named: assetName), ui.size.height > 0 {
            return ui.size.width / ui.size.height
        }
        if let data = item.imageData, let ui = UIImage(data: data), ui.size.height > 0 {
            return ui.size.width / ui.size.height
        }
        return 1
    }

    var body: some View {
        let width = canvasSize.width * item.relativeWidth
        let height = width / imageAspect
        let liveW = width * liveScale
        let liveH = height * liveScale
        let frameW = liveW + margin * 2
        let frameH = liveH + margin * 2
        let cx = frameW / 2
        let cy = frameH / 2

        ZStack {
            itemImage
                .frame(width: width, height: height)
                .scaleEffect(liveScale)
                .contentShape(Rectangle())
                .onTapGesture(perform: onTap)
                .position(x: cx, y: cy)

            if isSelected {
                Rectangle()
                    .stroke(Color.orange, lineWidth: 2)
                    .frame(width: liveW, height: liveH)
                    .position(x: cx, y: cy)
                    .allowsHitTesting(false)

                // Garis penghubung ke handle rotate
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 1.5, height: rotateHandleDistance)
                    .position(x: cx, y: cy - liveH / 2 - rotateHandleDistance / 2)
                    .allowsHitTesting(false)

                rotateHandle
                    .position(x: cx, y: cy - liveH / 2 - rotateHandleDistance)

                cornerHandle(sx: -1, sy: -1).position(x: cx - liveW / 2, y: cy - liveH / 2)
                cornerHandle(sx:  1, sy: -1).position(x: cx + liveW / 2, y: cy - liveH / 2)
                cornerHandle(sx: -1, sy:  1).position(x: cx - liveW / 2, y: cy + liveH / 2)
                cornerHandle(sx:  1, sy:  1).position(x: cx + liveW / 2, y: cy + liveH / 2)
            }
        }
        .frame(width: frameW, height: frameH)
        .background {
            // Lacak pusat item di ruang GLOBAL — dipakai gesture rotate.
            GeometryReader { geo in
                Color.clear
                    .onAppear { itemCenterGlobal = CGPoint(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY) }
                    .onChange(of: geo.frame(in: .global)) { _, f in
                        itemCenterGlobal = CGPoint(x: f.midX, y: f.midY)
                    }
            }
        }
        .rotationEffect(Angle(degrees: item.rotationDegrees) + liveRotation)
        .position(
            x: canvasSize.width * item.positionX + liveDrag.width,
            y: canvasSize.height * item.positionY + liveDrag.height
        )
        .zIndex(Double(item.zIndex))
        .opacity(item.isHidden ? 0 : 1)
        .allowsHitTesting(!item.isHidden)
        .gesture(dragGesture)
        .simultaneousGesture(pinchGesture)
        .simultaneousGesture(twoFingerRotateGesture)
    }

    @ViewBuilder
    private var itemImage: some View {
        if let assetName = item.assetName {
            Image(assetName).resizable().scaledToFit()
        } else if let data = item.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage).resizable().scaledToFit()
        }
    }

    // MARK: - Handles

    private func handleDot(icon: String? = nil) -> some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .overlay(Circle().stroke(Color.orange, lineWidth: 1.5))
                .frame(width: handleVisualSize, height: handleVisualSize)
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.orange)
            }
        }
        .frame(width: handleTouchSize, height: handleTouchSize)  // area sentuh 44pt
        .contentShape(Circle())
    }

    private var rotateHandle: some View {
        handleDot(icon: "arrow.triangle.2.circlepath")
            .gesture(rotateHandleGesture)
    }

    private func cornerHandle(sx: Double, sy: Double) -> some View {
        handleDot()
            .gesture(resizeHandleGesture(sx: sx, sy: sy))
    }

    // MARK: - Gesture: drag body (geser)

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard !item.isLocked else { return }
                liveDrag = value.translation
            }
            .onEnded { value in
                guard !item.isLocked else { return }
                liveDrag = .zero
                onDragEnded(value.translation)
            }
    }

    // MARK: - Gesture: resize via handle sudut (proporsional)

    private func resizeHandleGesture(sx: Double, sy: Double) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard !item.isLocked else { return }

                // Konversi translation (ruang layar) -> ruang lokal item
                // yang sedang ter-rotate, supaya arah tarikan tetap benar
                // di sudut rotasi berapa pun.
                let radians = item.rotationDegrees * .pi / 180
                let cosT = cos(radians), sinT = sin(radians)
                let tx = Double(value.translation.width)
                let ty = Double(value.translation.height)
                let localDx = tx * cosT + ty * sinT
                let localDy = -tx * sinT + ty * cosT

                let width = Double(canvasSize.width) * item.relativeWidth
                let height = width / Double(imageAspect)
                let hw = width / 2, hh = height / 2
                let startDist = (hw * hw + hh * hh).squareRoot()
                guard startDist > 0 else { return }

                let newX = sx * hw + localDx
                let newY = sy * hh + localDy
                let newDist = (newX * newX + newY * newY).squareRoot()

                liveScale = max(CGFloat(newDist / startDist), 0.15)
            }
            .onEnded { _ in
                guard !item.isLocked else { return }
                let finalScale = liveScale
                liveScale = 1.0
                onResizeEnded(finalScale)
            }
    }

    // MARK: - Gesture: rotate via handle atas

    private var rotateHandleGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                guard !item.isLocked else { return }

                let currentAngle = atan2(
                    Double(value.location.y - itemCenterGlobal.y),
                    Double(value.location.x - itemCenterGlobal.x)
                )

                if rotationStartFingerAngle == nil {
                    rotationStartFingerAngle = currentAngle
                }
                guard let startAngle = rotationStartFingerAngle else { return }

                accumulatedRotationDelta = (currentAngle - startAngle) * 180 / .pi
                liveRotation = Angle(degrees: accumulatedRotationDelta)
            }
            .onEnded { _ in
                guard !item.isLocked else { return }
                let delta = accumulatedRotationDelta
                liveRotation = .zero
                rotationStartFingerAngle = nil
                accumulatedRotationDelta = 0
                onRotateEnded(delta)
            }
    }

    // MARK: - Gesture dua-jari (alternatif, tetap didukung)

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                guard !item.isLocked else { return }
                liveScale = value
            }
            .onEnded { value in
                guard !item.isLocked else { return }
                liveScale = 1.0
                onResizeEnded(value)
            }
    }

    private var twoFingerRotateGesture: some Gesture {
        RotationGesture()
            .onChanged { value in
                guard !item.isLocked else { return }
                liveRotation = value
            }
            .onEnded { value in
                guard !item.isLocked else { return }
                liveRotation = .zero
                onRotateEnded(value.degrees)
            }
    }
}

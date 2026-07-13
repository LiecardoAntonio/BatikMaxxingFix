//
//  CanvasItemView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 12/07/26.
//

//  Item di canvas: tap = pilih; drag = geser; handle sudut = resize
//  proporsional; handle atas = rotate. Pinch & putar dua-jari HANYA
//  aktif saat item terpilih — selain itu sentuhan menembus ke container
//  (menjadi zoom canvas).
//
//  Catatan performa (hasil debugging bersama):
//  1. Live resize murni TRANSFORM (.scaleEffect di rantai luar) — TIDAK
//     mengubah .frame() per frame.
//  2. Gambar di-decode SEKALI (cachedImage + onAppear).
//  3. Pelacak pusat global hanya aktif saat item terpilih + tolak
//     tulisan state yang nilainya sama.
//
//  Catatan geometri:
//  - Frame dibungkus MARGIN SIMETRIS di semua sisi (ruang handle) supaya
//    pusat frame = pusat gambar -> .position() & .rotationEffect
//    (anchor .center) tetap presisi.
//  - Handle visual kecil (24pt), area sentuh 44pt (standar HIG).
//  - Resize: translation jari (ruang layar) dikonversi trigonometri ke
//    ruang lokal item yang ter-rotate.
//  - Rotate: DragGesture(coordinateSpace: .global) + pusat item global
//    dari GeometryReader; sudut dihitung dengan atan2 tanpa aproksimasi.
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

    // Snapshot untuk gesture handle rotate
    @State private var rotationStartFingerAngle: Double?
    @State private var accumulatedRotationDelta: Double = 0
    @State private var itemCenterGlobal: CGPoint = .zero

    /// Gambar di-decode SEKALI di onAppear — bukan di computed property
    /// yang dieksekusi ulang setiap frame gesture.
    @State private var cachedImage: UIImage?

    private let handleVisualSize: CGFloat = 24
    private let handleTouchSize: CGFloat = 44
    private let rotateHandleDistance: CGFloat = 40

    private var margin: CGFloat { rotateHandleDistance + handleTouchSize }

    /// Aspect ratio gambar (width/height) — dari cache, bukan decode ulang.
    private var imageAspect: CGFloat {
        guard let img = cachedImage, img.size.height > 0 else { return 1 }
        return img.size.width / img.size.height
    }

    var body: some View {
        let width = canvasSize.width * item.relativeWidth
        let height = width / imageAspect
        let frameW = width + margin * 2
        let frameH = height + margin * 2
        let cx = frameW / 2
        let cy = frameH / 2

        ZStack {
            itemImage
                .frame(width: width, height: height)
                .contentShape(Rectangle())
                .onTapGesture(perform: onTap)
                .position(x: cx, y: cy)

            if isSelected {
                Rectangle()
                    .stroke(Color.orange, lineWidth: 2)
                    .frame(width: width, height: height)
                    .position(x: cx, y: cy)
                    .allowsHitTesting(false)

                // Garis penghubung ke handle rotate
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 1.5, height: rotateHandleDistance)
                    .position(x: cx, y: cy - height / 2 - rotateHandleDistance / 2)
                    .allowsHitTesting(false)

                rotateHandle
                    .position(x: cx, y: cy - height / 2 - rotateHandleDistance)

                cornerHandle().position(x: cx - width / 2, y: cy - height / 2)
                cornerHandle().position(x: cx + width / 2, y: cy - height / 2)
                cornerHandle().position(x: cx - width / 2, y: cy + height / 2)
                cornerHandle().position(x: cx + width / 2, y: cy + height / 2)
            }
        }
        .frame(width: frameW, height: frameH)
        .background {
            // Pelacak pusat global HANYA saat terpilih — dibutuhkan gesture
            // rotate saja.
            if isSelected {
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            let f = geo.frame(in: .global)
                            itemCenterGlobal = CGPoint(x: f.midX, y: f.midY)
                        }
                        .onChange(of: geo.frame(in: .global)) { _, f in
                            let c = CGPoint(x: f.midX, y: f.midY)
                            if c != itemCenterGlobal { itemCenterGlobal = c }
                        }
                }
            }
        }
        .scaleEffect(liveScale)   // live resize murni TRANSFORM, bukan layout
        .rotationEffect(Angle(degrees: item.rotationDegrees) + liveRotation)
        .position(
            x: canvasSize.width * item.positionX + liveDrag.width,
            y: canvasSize.height * item.positionY + liveDrag.height
        )
        .zIndex(Double(item.zIndex))
        .opacity(item.isHidden ? 0 : 1)
        .allowsHitTesting(!item.isHidden)
        .gesture(dragGesture)
        // Dua-jari HANYA saat terpilih (.gesture); selain itu dimatikan
        // total (.none) supaya pinch menembus ke container = zoom canvas.
        .simultaneousGesture(pinchGesture, including: isSelected ? .gesture : .none)
        .simultaneousGesture(twoFingerRotateGesture, including: isSelected ? .gesture : .none)
        .onAppear {
            // Decode gambar SEKALI per kemunculan item.
            if cachedImage == nil {
                if let assetName = item.assetName {
                    cachedImage = UIImage(named: assetName)
                } else if let data = item.imageData {
                    cachedImage = UIImage(data: data)
                }
            }
        }
    }

    @ViewBuilder
    private var itemImage: some View {
        if let cachedImage {
            Image(uiImage: cachedImage)
                .resizable()
                .scaledToFit()
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

    private func cornerHandle() -> some View {
        handleDot()
            .gesture(resizeHandleGesture)
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

    private var resizeHandleGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                guard !item.isLocked else { return }

                let startDist = hypot(
                    value.startLocation.x - itemCenterGlobal.x,
                    value.startLocation.y - itemCenterGlobal.y
                )
                guard startDist > 1 else { return }

                let currentDist = hypot(
                    value.location.x - itemCenterGlobal.x,
                    value.location.y - itemCenterGlobal.y
                )

                liveScale = max(currentDist / startDist, 0.15)
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

    // MARK: - Gesture dua-jari (alternatif handle, hanya saat terpilih)

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

//
//  CanvasView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 10/07/26.
//

//  Layar canvas: foto badan sebagai acuan, item pakaian bisa
//  ditaruh/digeser di atasnya, tray di bawah, toolbar untuk item terpilih.
//
//  Catatan performa (hasil debugging bersama):
//  1. Transform > layout: semua perubahan visual per-frame (pan, live
//     resize) lewat offset/scaleEffect — tidak menyentuh frame/layout.
//  2. Grid pakai teknik FASE: digambar seukuran layar dan tidak pernah
//     bergeser — hanya fase titiknya yang mengikuti pan (modulo spacing).
//  3. Foto badan di-decode SEKALI per sesi (@State + onAppear) dan
//     di-downsample untuk tampilan — decode di computed property akan
//     terpanggil ulang SETIAP frame gesture (penyebab freeze 60-500ms).
//

import SwiftUI
import SwiftData

struct CanvasView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.undoManager) private var undoManager

    @Bindable var canvas: CanvasDataModel
    let onAddClothes: () -> Void

    @State private var viewModel = CanvasViewModel()

    // Pan canvas — UI-lokal per sesi (tidak di-persist)
    @State private var panOffset: CGSize = .zero
    @GestureState private var livePan: CGSize = .zero
    
    // Zoom canvas — UI-lokal per sesi, sama seperti pan
    @State private var zoomScale: CGFloat = 1.0
    @GestureState private var liveZoom: CGFloat = 1.0

    /// Foto badan: di-decode SEKALI di onAppear (bukan computed property!)
    /// dan di-downsample supaya GPU tidak memindahkan tekstur raksasa
    /// setiap frame pan.
//    @State private var bodyImage: UIImage?

    private var placedItems: [CanvasItemModel] {
        canvas.items.filter(\.isPlaced).sorted { $0.zIndex < $1.zIndex }
    }

    private var trayItems: [CanvasItemModel] {
        canvas.items.filter { !$0.isBodyPhoto }.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()   // dasar statis, paling belakang

            GeometryReader { geo in
                ZStack {
                    // Grid: seukuran layar, TIDAK ikut di-offset — hanya
                    // FASE titiknya yang digeser oleh nilai pan.
                    DotGridBackground(offset: CGSize(
                        width: panOffset.width + livePan.width,
                        height: panOffset.height + livePan.height
                    ))
                    .ignoresSafeArea()

                    // Lapisan yang benar-benar bergeser: foto + item saja
                    ZStack {
//                        if let bodyImage {
//                            Image(uiImage: bodyImage)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: geo.size.width * 0.75)
//                                .position(x: geo.size.width / 2, y: geo.size.height / 2)
//                                .onTapGesture { viewModel.deselect() }
//                        }

                        ForEach(placedItems) { item in
                            CanvasItemView(
                                item: item,
                                isSelected: viewModel.isSelected(item),
                                canvasSize: geo.size,
                                onTap: { viewModel.select(item) },
                                onDragEnded: { translation in
                                    viewModel.commitDrag(item, translation: translation, canvasSize: geo.size, on: canvas)
                                },
                                onResizeEnded: { scale in
                                    viewModel.commitResize(item, scale: scale, on: canvas)
                                },
                                onRotateEnded: { degrees in
                                    viewModel.commitRotation(item, degrees: degrees, on: canvas)
                                }
                            )
                        }
                    }
                    .scaleEffect(zoomScale * liveZoom)
                    .offset(
                        x: panOffset.width + livePan.width,
                        y: panOffset.height + livePan.height
                    )
                }
                .contentShape(Rectangle())
                .onTapGesture { viewModel.deselect() }   // tap area kosong = deselect
                .gesture(canvasPanGesture(bounds: geo.size))
                .simultaneousGesture(canvasZoomGesture, including: viewModel.selectedItemID == nil ? .all : .subviews) // biar ga zoom bareng resize
            }

            // UI overlay — menempel layar, TIDAK ikut ter-offset
            VStack {
                topBar
                Spacer()

                itemToolbar
                    .opacity(viewModel.selectedItem(in: canvas) != nil ? 1 : 0)
                    .allowsHitTesting(viewModel.selectedItem(in: canvas) != nil)
                    .padding(.bottom, 8)

                CanvasTrayView(
                    items: trayItems,
                    isItemSelected: { viewModel.isSelected($0) },
                    onItemTapped: { viewModel.placeOrSelect($0, on: canvas) },
                    onAddTapped: onAddClothes
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // Undo/redo scoped per sesi canvas: riwayat dikosongkan setiap
            // kali canvas dibuka.
            undoManager?.removeAllActions()

            // Decode foto badan SEKALI per sesi + downsample untuk tampilan
            // (database tetap menyimpan resolusi asli).
//            if bodyImage == nil, let data = canvas.fullBodyPicData {
//                bodyImage = UIImage(data: data)?.downsampled(maxDimension: 1200)
//            }
        }
    }

    // MARK: - Pan canvas

    private func canvasPanGesture(bounds: CGSize) -> some Gesture {
        DragGesture()
            .updating($livePan) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                let proposedX = panOffset.width + value.translation.width
                let proposedY = panOffset.height + value.translation.height
                // Clamp: maksimal menjelajah satu layar ke tiap arah.
                panOffset = CGSize(
                    width: min(max(proposedX, -bounds.width), bounds.width),
                    height: min(max(proposedY, -bounds.height), bounds.height)
                )
            }
    }
    
    private var canvasZoomGesture: some Gesture {
            MagnificationGesture()
                .updating($liveZoom) { value, state, _ in
                    state = value
                }
                .onEnded { value in
                    // Clamp 0.5x - 3x
                    zoomScale = min(max(zoomScale * value, 0.5), 3.0)
                }
        }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .glassEffect()
            }

            Spacer()

            HStack(spacing: 0) {
                Button {
                    undoManager?.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .frame(width: 44, height: 44)
                        .foregroundStyle((undoManager?.canUndo ?? false) ? .black : Color.gray.opacity(0.45))
                }
                .disabled(!(undoManager?.canUndo ?? false))

                Button {
                    undoManager?.redo()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                        .frame(width: 44, height: 44)
                        .foregroundStyle((undoManager?.canRedo ?? false) ? .black : Color.gray.opacity(0.45))
                }
                .disabled(!(undoManager?.canRedo ?? false))
            }
            .font(.system(size: 16, weight: .medium))
            .glassEffect(.regular, in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Toolbar item terpilih

    private var itemToolbar: some View {
        HStack(spacing: 20) {
            toolbarButton("eye") { viewModel.toggleHidden(on: canvas) }
            toolbarButton("plus.square.on.square") { viewModel.duplicateSelected(on: canvas, in: modelContext) }
            toolbarButton("square.3.layers.3d.top.filled") { viewModel.bringForward(on: canvas) }
            toolbarButton("square.3.layers.3d.bottom.filled") { viewModel.sendBackward(on: canvas) }
            toolbarButton(viewModel.selectedItem(in: canvas)?.isLocked == true ? "lock.fill" : "lock") {
                viewModel.toggleLock(on: canvas)
            }

            Button {
                viewModel.deleteSelected(on: canvas, in: modelContext)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(
                        viewModel.selectedItem(in: canvas)?.isBodyPhoto == true
                            ? Color.gray.opacity(0.45)
                            : .red
                    )
            }
            .disabled(viewModel.selectedItem(in: canvas)?.isBodyPhoto == true)
        }
        .font(.system(size: 17))
        .foregroundStyle(.black)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: Capsule())
    }

    private func toolbarButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
        }
    }
}

// MARK: - Background dot grid (seperti Figma)

struct DotGridBackground: View {
    /// Total pan (committed + live). Grid tidak benar-benar bergeser —
    /// hanya FASE titiknya (offset modulo spacing), jadi terasa tak
    /// berujung tanpa perlu canvas 3x layar / tekstur raksasa.
    var offset: CGSize = .zero

    private let spacing: CGFloat = 24
    private let dotSize: CGFloat = 2.5

    var body: some View {
        Canvas { context, size in
            let phaseX = offset.width.truncatingRemainder(dividingBy: spacing)
            let phaseY = offset.height.truncatingRemainder(dividingBy: spacing)

            var x = phaseX - spacing
            while x < size.width + spacing {
                var y = phaseY - spacing
                while y < size.height + spacing {
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: dotSize, height: dotSize)),
                        with: .color(Color(red: 0.85, green: 0.85, blue: 0.85))
                    )
                    y += spacing
                }
                x += spacing
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    NavigationStack {
        CanvasView(canvas: CanvasDataModel(name: "Preview"), onAddClothes: { })
    }
    .modelContainer(for: [
        CanvasDataModel.self,
        CanvasItemModel.self,
        UserFullBodyImageModel.self,
        UserOutfitModel.self
    ], inMemory: true)
}

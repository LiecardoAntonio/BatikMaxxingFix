//
//  CanvasView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 10/07/26.
//

//  Layar canvas: foto badan sebagai acuan (terkunci), item pakaian bisa
//  ditaruh/digeser di atasnya, tray di bawah, toolbar untuk item terpilih.
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

    private var bodyImage: UIImage? {
        guard let data = canvas.fullBodyPicData else { return nil }
        return UIImage(data: data)
    }

    private var placedItems: [CanvasItemModel] {
        canvas.items.filter(\.isPlaced).sorted { $0.zIndex < $1.zIndex }
    }

    private var trayItems: [CanvasItemModel] {
        canvas.items.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        ZStack {
            DotGridBackground()

            GeometryReader { geo in
                ZStack {
                    // Foto badan: acuan, tidak bisa digeser
                    if let bodyImage {
                        Image(uiImage: bodyImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.75)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                            .onTapGesture { viewModel.deselect() }
                    }

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
                .contentShape(Rectangle())
            }

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
            // kali canvas dibuka — hanya perubahan sesi ini yang bisa
            // di-undo (requirement produk).
            undoManager?.removeAllActions()
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

    // MARK: - Toolbar item terpilih (Figma: eye, duplicate, layers, lock, trash)

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
                    .foregroundStyle(.red)
            }
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
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 24
            var x: CGFloat = 12
            while x < size.width {
                var y: CGFloat = 12
                while y < size.height {
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: 2.5, height: 2.5)),
                        with: .color(Color(red: 0.85, green: 0.85, blue: 0.85))
                    )
                    y += spacing
                }
                x += spacing
            }
        }
        .ignoresSafeArea()
        .background(Color.white)
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

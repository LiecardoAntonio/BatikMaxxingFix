//
//  CanvasViewModel.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 12/07/26.
//

//  State & logic layar canvas: penempatan item dari tray, seleksi,
//  drag, dan aksi toolbar (hide/duplicate/layer/lock/delete).
//  KONTRAK: setiap perubahan isi canvas memanggil canvas.updateLastUpdated()
//  supaya sort di grid Home tetap jujur.
//

import SwiftUI
import SwiftData

@Observable
final class CanvasViewModel {

    /// Item yang sedang terpilih (toolbar beroperasi pada item ini).
    var selectedItemID: PersistentIdentifier?

    // MARK: - Seleksi

    func select(_ item: CanvasItemModel) {
        selectedItemID = item.persistentModelID
    }

    func deselect() {
        selectedItemID = nil
    }

    func isSelected(_ item: CanvasItemModel) -> Bool {
        selectedItemID == item.persistentModelID
    }

    // MARK: - Penempatan dari tray

    /// Tap item di tray: taruh di canvas (posisi tengah default) dan pilih.
    /// Kalau sudah placed, cukup pilih (untuk dioperasikan toolbar).
    func placeOrSelect(_ item: CanvasItemModel, on canvas: CanvasDataModel) {
        if !item.isPlaced {
            item.isPlaced = true
            item.zIndex = (canvas.items.map(\.zIndex).max() ?? 0) + 1
            canvas.updateLastUpdated()
        }
        select(item)
    }

    // MARK: - Drag (commit di akhir gesture; live offset urusan View)

    func commitDrag(_ item: CanvasItemModel, translation: CGSize, canvasSize: CGSize, on canvas: CanvasDataModel) {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return }
        item.positionX = (item.positionX + Double(translation.width / canvasSize.width)).clamped(to: 0...1)
        item.positionY = (item.positionY + Double(translation.height / canvasSize.height)).clamped(to: 0...1)
        canvas.updateLastUpdated()
    }

    // MARK: - Aksi toolbar (beroperasi pada item terpilih)

    func selectedItem(in canvas: CanvasDataModel) -> CanvasItemModel? {
        canvas.items.first { isSelected($0) }
    }

    func toggleHidden(on canvas: CanvasDataModel) {
        guard let item = selectedItem(in: canvas) else { return }
        item.isHidden.toggle()
        canvas.updateLastUpdated()
    }

    func duplicateSelected(on canvas: CanvasDataModel, in context: ModelContext) {
        guard let item = selectedItem(in: canvas) else { return }
        let copy = CanvasItemModel(assetName: item.assetName, imageData: item.imageData)
        copy.isBodyPhoto = false   // so that the duplicated body image can be deleted
        copy.isPlaced = true
        copy.positionX = (item.positionX + 0.05).clamped(to: 0...1)
        copy.positionY = (item.positionY + 0.05).clamped(to: 0...1)
        copy.relativeWidth = item.relativeWidth
        copy.zIndex = (canvas.items.map(\.zIndex).max() ?? 0) + 1
        context.insert(copy)
        copy.canvas = canvas
        canvas.updateLastUpdated()
        select(copy)
    }

    func bringForward(on canvas: CanvasDataModel) {
        guard let item = selectedItem(in: canvas) else { return }
        let ordered = canvas.items.filter(\.isPlaced).sorted { $0.zIndex < $1.zIndex }
        guard let index = ordered.firstIndex(where: { $0.persistentModelID == item.persistentModelID }),
              index < ordered.count - 1 else { return }   // sudah paling depan

        let neighborAbove = ordered[index + 1]
        let temp = item.zIndex
        item.zIndex = neighborAbove.zIndex
        neighborAbove.zIndex = temp
        canvas.updateLastUpdated()
    }

    func sendBackward(on canvas: CanvasDataModel) {
        guard let item = selectedItem(in: canvas) else { return }
        let ordered = canvas.items.filter(\.isPlaced).sorted { $0.zIndex < $1.zIndex }
        guard let index = ordered.firstIndex(where: { $0.persistentModelID == item.persistentModelID }),
              index > 0 else { return }   // sudah paling belakang

        let neighborBelow = ordered[index - 1]
        let temp = item.zIndex
        item.zIndex = neighborBelow.zIndex
        neighborBelow.zIndex = temp
        canvas.updateLastUpdated()
    }

    func toggleLock(on canvas: CanvasDataModel) {
        guard let item = selectedItem(in: canvas) else { return }
        item.isLocked.toggle()
        canvas.updateLastUpdated()
    }

//    func deleteSelected(on canvas: CanvasDataModel, in context: ModelContext) {
//        guard let item = selectedItem(in: canvas), !item.isBodyPhoto else { return }
//        context.delete(item)
//        canvas.updateLastUpdated()
//        deselect()
//    }
    
    // MARK: - Resize & Rotate (commit di akhir gesture)
    func commitResize(_ item: CanvasItemModel, scale: CGFloat, on canvas: CanvasDataModel) {
        // Clamp supaya item tidak lenyap (terlalu kecil) atau menelan layar
        item.relativeWidth = (item.relativeWidth * Double(scale)).clamped(to: 0.08...1.5)
        canvas.updateLastUpdated()
    }

    func commitRotation(_ item: CanvasItemModel, degrees: Double, on canvas: CanvasDataModel) {
        item.rotationDegrees += degrees
        canvas.updateLastUpdated()
    }

    /// onConfirm library (mode add-clothes) = daftar FINAL pilihan canvas.
    /// Item lama yang tidak ada di daftar -> dihapus dari canvas & tray;
    /// item baru -> ditambahkan.
    func syncItems(_ selectedItems: Set<ClothingItem>, on canvas: CanvasDataModel, in context: ModelContext) {
        let selectedIDs = Set(selectedItems.map(\.id))

        // Hapus yang di-unselect (snapshot dulu — jangan mutasi koleksi
        // yang sedang di-iterate)
        let currentItems = canvas.items
        for item in currentItems {
            guard let sourceID = item.sourceID else { continue }
            if !selectedIDs.contains(sourceID) {
                if isSelected(item) { deselect() }
                context.delete(item)
            }
        }

        // Tambah yang baru
        let existingIDs = Set(canvas.items.compactMap(\.sourceID))
        for item in selectedItems where !existingIDs.contains(item.id) {
            let canvasItem: CanvasItemModel
            switch item.source {
            case .bundled(let assetName):
                canvasItem = CanvasItemModel(assetName: assetName)
            case .userUpload(_, let imageData):
                canvasItem = CanvasItemModel(imageData: imageData)
            }
            canvasItem.sourceID = item.id
            context.insert(canvasItem)
            canvasItem.canvas = canvas
        }

        canvas.updateLastUpdated()
    }
    
    // MARK: - Thumbnail

    /// Render isi canvas jadi thumbnail untuk card grid. Dipanggil saat
    /// user meninggalkan canvas. ImageRenderer wajib di main thread.
    @MainActor
    func generateThumbnail(for canvas: CanvasDataModel, canvasSize: CGSize) {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return }

        let visibleItems = canvas.items
            .filter { $0.isPlaced && !$0.isHidden }
            .sorted { $0.zIndex < $1.zIndex }
        guard !visibleItems.isEmpty else { return }

        // Render di setengah ukuran canvas — cukup tajam untuk card 140pt,
        // jauh lebih kecil di penyimpanan.
        let renderSize = CGSize(width: canvasSize.width / 2, height: canvasSize.height / 2)
        let renderer = ImageRenderer(
            content: CanvasSnapshotView(items: visibleItems, size: renderSize)
        )
        renderer.scale = 2.0

        guard let uiImage = renderer.uiImage,
              let data = uiImage.jpegData(compressionQuality: 0.7) else { return }
        // JPEG (bukan PNG): thumbnail tidak butuh transparansi — latar
        // putih sudah dirender — dan jauh lebih kecil.

        canvas.thumbnailPicData = data
        // SENGAJA tidak memanggil updateLastUpdated(): membuat thumbnail
        // bukan "edit" — jangan mengubah urutan sort di grid.
    }
    
    /// Hapus item tertentu (dipakai tombol "−" di tray & trash toolbar).
    /// Foto badan tetap kebal.
    func deleteItem(_ item: CanvasItemModel, on canvas: CanvasDataModel, in context: ModelContext) {
        guard !item.isBodyPhoto else { return }
        if isSelected(item) { deselect() }
        context.delete(item)
        canvas.updateLastUpdated()
    }

    func deleteSelected(on canvas: CanvasDataModel, in context: ModelContext) {
        guard let item = selectedItem(in: canvas) else { return }
        deleteItem(item, on: canvas, in: context)
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

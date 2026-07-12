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

    func deleteSelected(on canvas: CanvasDataModel, in context: ModelContext) {
        guard let item = selectedItem(in: canvas) else { return }
        context.delete(item)
        canvas.updateLastUpdated()
        deselect()
    }

    // MARK: - Tambah item dari library (mode add-clothes)

    func addItems(_ selectedItems: Set<ClothingItem>, to canvas: CanvasDataModel, in context: ModelContext) {
        for item in selectedItems {
            let canvasItem: CanvasItemModel
            switch item.source {
            case .bundled(let assetName):
                canvasItem = CanvasItemModel(assetName: assetName)
            case .userUpload(_, let imageData):
                canvasItem = CanvasItemModel(imageData: imageData)
            }
            context.insert(canvasItem)
            canvasItem.canvas = canvas
        }
        canvas.updateLastUpdated()
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

//
//  CanvasGridViewModel.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 11/07/26.
//

import SwiftUI
import SwiftData

@Observable
final class CanvasGridViewModel {

    // MARK: - Rename

    var canvasToRename: CanvasDataModel?
    var renameText: String = ""
    var isRenamePresented: Bool = false
    
    var searchText: String = ""

    func beginRename(_ canvas: CanvasDataModel) {
        canvasToRename = canvas
        renameText = canvas.name
        isRenamePresented = true
    }

    func commitRename() {
        guard let canvas = canvasToRename else { return }

        let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            isRenamePresented = false
            return
        }

        canvas.name = trimmed
        canvas.updateLastUpdated()
        isRenamePresented = false
        canvasToRename = nil
    }

    // MARK: - Delete (dua langkah: minta konfirmasi dulu, baru eksekusi)

    var canvasToDelete: CanvasDataModel?
    var isDeleteConfirmationPresented: Bool = false

    func requestDelete(_ canvas: CanvasDataModel) {
        canvasToDelete = canvas
        isDeleteConfirmationPresented = true
    }

    func confirmDelete(in context: ModelContext) {
        guard let canvas = canvasToDelete else { return }
        context.delete(canvas)
        canvasToDelete = nil
        isDeleteConfirmationPresented = false
    }
    
    /// Filter case-insensitive. localizedCaseInsensitiveContains itu cara
    /// idiomatic Swift: "Kondangan".localizedCaseInsensitiveContains("kon") == true
    func filteredCanvases(from canvases: [CanvasDataModel]) -> [CanvasDataModel] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return canvases }
        return canvases.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }

    // MARK: - Create

    func createCanvas(in context: ModelContext, onCreated: (CanvasDataModel) -> Void) {
        let newCanvas = CanvasDataModel(name: "Untitled")
        context.insert(newCanvas)
        onCreated(newCanvas)
    }
}

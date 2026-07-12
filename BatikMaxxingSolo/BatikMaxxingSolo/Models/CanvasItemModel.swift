//
//  CanvasItemModel.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 11/07/26.
//

//  Satu pakaian PILIHAN milik sebuah canvas. Dua kemungkinan sumber,
//  tepat satu yang terisi:
//  - assetName  → item koleksi bawaan (referensi ke Assets, hemat memori;
//                 aman karena asset bundle tidak bisa berubah/hilang)
//  - imageData  → item upload user (SALINAN/snapshot, supaya canvas tetap
//                 utuh walau user menghapus item itu dari My Outfits)
//

import Foundation
import SwiftData

@Model
class CanvasItemModel {
    var assetName: String?
    @Attribute(.externalStorage) var imageData: Data?
    var createdAt: Date = Date()

    // MARK: - Penempatan di canvas
    /// false = masih di tray saja; true = sudah ditaruh di atas foto badan.
    var isPlaced: Bool = false
    /// Posisi TITIK TENGAH item, dalam koordinat relatif 0...1 terhadap
    /// ukuran canvas (bukan piksel!) — supaya konsisten di semua ukuran
    /// layar/device.
    var positionX: Double = 0.5
    var positionY: Double = 0.5
    /// Lebar item relatif terhadap lebar canvas (0...1). Tinggi mengikuti
    /// aspect ratio gambar.
    var relativeWidth: Double = 0.4
    /// Urutan tumpukan: makin besar makin depan.
    var zIndex: Int = 0
    var isLocked: Bool = false
    var isHidden: Bool = false
    
    /// ID ClothingItem asal (assetName untuk bundled, UUID untuk upload).
    /// Dipakai untuk menandai item yang sudah ada saat buka library lagi.
    var sourceID: String?

    var canvas: CanvasDataModel?

    init(assetName: String? = nil, imageData: Data? = nil) {
        self.assetName = assetName
        self.imageData = imageData
    }
}

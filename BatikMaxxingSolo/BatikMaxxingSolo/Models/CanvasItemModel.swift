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

    var canvas: CanvasDataModel?

    init(assetName: String? = nil, imageData: Data? = nil) {
        self.assetName = assetName
        self.imageData = imageData
    }
}

//
//  CanvasDataModel.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 09/07/26.
//

import Foundation
import SwiftData


// this is called a Data Model so that u can save something to the local storage of the device, it uses SwiftData now but back then they use CoreData

// you use class because it has to be single source of truth
@Model
class CanvasDataModel: Identifiable {
    var id: UUID
    var name: String
    //    var thumbnailPicData: String
    @Attribute(.externalStorage) var thumbnailPicData: Data? // we use this instead of the above code because the above code saves the path to the image in string, if the canvas is deleted, only the path will be deleted and the image will still be saved in the storage:( (this is called orphan file)
    @Attribute(.externalStorage) var fullBodyPicData: Data? //this is needed because every canvas will save it's own fullbody image
    var createdAt: Date = Date()
    var lastUpdated: Date = Date()
    
    /// Pakaian-pakaian pilihan canvas ini. .cascade: hapus canvas -> semua
    /// catatan pilihannya ikut terhapus (mencegah orphan record).
    @Relationship(deleteRule: .cascade, inverse: \CanvasItemModel.canvas)
    var items: [CanvasItemModel] = []
    
    init(name: String, fullBodyPicData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.fullBodyPicData = fullBodyPicData
        // the rest doesn't have to be initialized, coz 1 is optional, 2 and 3 is self defined
    }
}

extension CanvasDataModel {
    func updateLastUpdated() {
        lastUpdated = .now
    }
}

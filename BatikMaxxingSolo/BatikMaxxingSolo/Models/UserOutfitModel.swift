//
//  UserOutfitModel.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 11/07/26.
//

//  Pakaian yang di-upload user ke "My Outfits". Data level-app (global):
//  tidak terikat canvas manapun — sama seperti UserFullBodyImageModel.
//

import Foundation
import SwiftData

@Model
class UserOutfitModel {
    var id: UUID
    @Attribute(.externalStorage) var imageData: Data?
    var createdAt: Date = Date()

    init(imageData: Data? = nil) {
        self.id = UUID()
        self.imageData = imageData
    }
}

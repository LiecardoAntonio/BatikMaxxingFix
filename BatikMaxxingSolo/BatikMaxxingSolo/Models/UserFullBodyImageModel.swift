//
//  UserFullBodyImageModel.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 10/07/26.
//

import Foundation
import SwiftData

@Model
class UserFullBodyImageModel {
    @Attribute(.externalStorage) var fullBodyPicData: Data?

    init(fullBodyPicData: Data? = nil) {
        self.fullBodyPicData = fullBodyPicData
    }
}

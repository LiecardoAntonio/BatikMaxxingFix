//
//  HomeRoute.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 11/07/26.
//

//  Rute navigasi dari HomeView. Navigasi berbasis data: tumpukan layar
//  direpresentasikan sebagai array [HomeRoute] — push = append,
//  pop = removeLast, ganti tumpukan = assign array baru.
//

import Foundation

enum HomeRoute: Hashable {
    case librarySelection            // pilih baju untuk canvas BARU
    case canvas(CanvasDataModel)     // buka sebuah canvas
}

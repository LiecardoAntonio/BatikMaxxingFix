//
//  CameraPickerView.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 11/07/26.
//

//  Jembatan UIKit->SwiftUI untuk kamera. UIImagePickerController adalah
//  komponen UIKit lama; UIViewControllerRepresentable membungkusnya
//  supaya bisa dipakai sebagai View SwiftUI biasa.
//

import SwiftUI
import UIKit

struct CameraPickerView: UIViewControllerRepresentable {
    /// Dipanggil saat user selesai memotret. Nil kalau user cancel.
    let onImageCaptured: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .rear
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Tidak ada yang perlu di-update setelah dibuat.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured)
    }

    /// Coordinator = penerjemah dari delegate pattern UIKit ke closure SwiftUI.
    /// UIImagePickerController "melapor" ke delegate-nya (objek ini), lalu
    /// kita teruskan hasilnya lewat closure.
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageCaptured: (UIImage?) -> Void

        init(onImageCaptured: @escaping (UIImage?) -> Void) {
            self.onImageCaptured = onImageCaptured
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = info[.originalImage] as? UIImage
            onImageCaptured(image)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onImageCaptured(nil)
        }
    }
}

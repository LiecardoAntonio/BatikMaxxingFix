//
//  BackgroundRemovalService.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 10/07/26.
//

import Vision
import UIKit
import CoreImage

final class BackgroundRemovalService {
    
    // in case error, so we know what makes it error
    enum BackgroundRemovalError: Error {
        case cgImageUnavailable
        case noSubjectFound
        case maskGenerationFailed
    }
    
    private let context = CIContext()
    
    func removeBackground(from image: UIImage) async throws -> UIImage {
            guard let cgImage = image.cgImage else {
                throw BackgroundRemovalError.cgImageUnavailable
            }

            let orientation = cgOrientation(from: image.imageOrientation)

            let request = VNGenerateForegroundInstanceMaskRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])

            try handler.perform([request])

            guard let result = request.results?.first, !result.allInstances.isEmpty else {
                throw BackgroundRemovalError.noSubjectFound
            }

            // Ambil semua instance yang terdeteksi jadi satu masked image
            // (background otomatis jadi transparan).
            let maskedPixelBuffer = try result.generateMaskedImage(
                ofInstances: result.allInstances,
                from: handler,
                croppedToInstancesExtent: false
            )

            let maskedCIImage = CIImage(cvPixelBuffer: maskedPixelBuffer)

            guard let outputCGImage = context.createCGImage(maskedCIImage, from: maskedCIImage.extent) else {
                throw BackgroundRemovalError.maskGenerationFailed
            }

            return UIImage(cgImage: outputCGImage, scale: image.scale, orientation: .up)
        }
    
        /// Vision butuh orientasi dalam tipe `CGImagePropertyOrientation`, beda
        /// dengan `UIImage.Orientation` — kalau tidak dikonversi, foto dari
        /// kamera (yang sering punya orientation .right) bisa keluar
        /// ter-rotate salah.
        private func cgOrientation(from uiOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
            switch uiOrientation {
            case .up: return .up
            case .down: return .down
            case .left: return .left
            case .right: return .right
            case .upMirrored: return .upMirrored
            case .downMirrored: return .downMirrored
            case .leftMirrored: return .leftMirrored
            case .rightMirrored: return .rightMirrored
            @unknown default: return .up
            }
        }
}

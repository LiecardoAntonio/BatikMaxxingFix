//
//  UIImage_Downsample.swift
//  BatikMaxxingSolo
//
//  Created by Liecardo on 13/07/26.
//

import UIKit

extension UIImage {
    /// Turunkan resolusi ke maxDimension di sisi terpanjang — cukup untuk
    /// tampilan layar, jauh lebih ringan untuk GPU per frame.
    func downsampled(maxDimension: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return self }
        let scaleFactor = maxDimension / longest
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

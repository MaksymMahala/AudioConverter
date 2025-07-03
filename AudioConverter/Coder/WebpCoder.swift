//
//  WebpCoder.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import Foundation
import SDWebImage
import SDWebImageWebPCoder

class WebpCoder {
    static func registerWebPCoder() {
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)
    }
    
    static func exportToWebP(image: UIImage, completion: @escaping (URL?) -> Void) {
        let coder = SDImageWebPCoder.shared

        let options: [SDImageCoderOption: Any] = [
            .encodeCompressionQuality: 1.0
        ]

        guard let webpData = coder.encodedData(with: image, format: .webP, options: options) else {
            completion(nil)
            return
        }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("webp")

        do {
            try webpData.write(to: outputURL)
            completion(outputURL)
        } catch {
            print("Failed to write WebP file: \(error)")
            completion(nil)
        }
    }
}

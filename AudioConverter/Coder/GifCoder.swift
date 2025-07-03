//
//  GifCoder.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import Foundation
import SDWebImage

class GifCoder {
    static func exportToGIF(image: UIImage, completion: @escaping (URL?) -> Void) {
        let coder = SDImageGIFCoder.shared

        // Options can include loop count, delay time, etc.
        let options: [SDImageCoderOption: Any] = [:]

        guard let gifData = coder.encodedData(with: image, format: .GIF, options: options) else {
            completion(nil)
            return
        }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("gif")

        do {
            try gifData.write(to: outputURL)
            completion(outputURL)
        } catch {
            print("Failed to write GIF file: \(error)")
            completion(nil)
        }
    }
}

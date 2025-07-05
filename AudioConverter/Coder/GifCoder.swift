//
//  GifCoder.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import SDWebImage
import UIKit
import ImageIO
import MobileCoreServices

class GifCoder {
    static func exportToGIF(image: UIImage, completion: @escaping (URL?) -> Void) {
        let coder = SDImageGIFCoder.shared

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

enum GIFExporter {
    static func createGIF(from image: UIImage, frameCount: Int, frameDuration: Double, loopCount: Int, size: CGSize) -> URL? {
        let maxFrames = 100  // lowered max frames for safety
        let safeFrameCount = min(frameCount, 1)
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).gif")
        
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypeGIF, safeFrameCount, nil) else {
            print("❌ Failed to create GIF destination")
            return nil
        }
        
        // Resize once before loop
        let resizedImage = image.resize(to: size)
        
        let frameProperties = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: frameDuration
            ]
        ]
        
        let gifProperties = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: loopCount
            ]
        ]
        
        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
        
        for _ in 0..<safeFrameCount {
            autoreleasepool {
                if let cgImage = resizedImage.cgImage {
                    CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
                }
            }
        }
        
        if CGImageDestinationFinalize(destination) {
            return fileURL
        } else {
            print("❌ Failed to finalize GIF")
            return nil
        }
    }
}

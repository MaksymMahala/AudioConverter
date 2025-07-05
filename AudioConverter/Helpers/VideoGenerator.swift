//
//  VideoGenerator.swift
//  AudioConverter
//
//  Created by Max on 02.07.2025.
//

import AVFoundation
import UIKit

enum VideoGenerator {
    static func createVideoFromAudio(audioURL: URL, outputFormat: String, completion: @escaping (URL?) -> Void) {
        let size = CGSize(width: 1080, height: 1920)
        
        let audioAsset = AVURLAsset(url: audioURL)
        let duration = CMTimeGetSeconds(audioAsset.duration)
        
        guard duration > 0 else {
            print("❌ Audio duration is zero")
            completion(nil)
            return
        }
        
        let (fileExtension, fileType) = fileExtensionAndType(for: outputFormat)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "." + fileExtension)
        
        do {
            let writer = try AVAssetWriter(outputURL: outputURL, fileType: fileType)
            
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: size.width,
                AVVideoHeightKey: size.height
            ]
            
            let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            writerInput.expectsMediaDataInRealTime = false
            
            let sourceBufferAttributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: size.width,
                kCVPixelBufferHeightKey as String: size.height
            ]
            
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: writerInput,
                sourcePixelBufferAttributes: sourceBufferAttributes
            )
            
            guard writer.canAdd(writerInput) else {
                print("❌ Cannot add writer input")
                completion(nil)
                return
            }
            
            writer.add(writerInput)
            
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)
            
            let fps: Int32 = 30
            let frameDuration = CMTime(value: 1, timescale: fps)
            let totalFrames = Int(duration * Double(fps))
            var frameCount: Int64 = 0
            
            let queue = DispatchQueue(label: "video.generator.queue")
            writerInput.requestMediaDataWhenReady(on: queue) {
                while writerInput.isReadyForMoreMediaData && frameCount < Int64(totalFrames) {
                    let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                    if let pixelBuffer = createPixelBuffer(size: size, color: .black) {
                        pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                    }
                    frameCount += 1
                }
                
                if frameCount >= Int64(totalFrames) {
                    writerInput.markAsFinished()
                    writer.finishWriting {
                        mergeAudioWithVideo(videoURL: outputURL, audioURL: audioURL, outputFileType: fileType, completion: completion)
                    }
                }
            }
        } catch {
            print("Writer error: \(error)")
            completion(nil)
        }
    }

    private static func fileExtensionAndType(for format: String) -> (String, AVFileType) {
        switch format.lowercased() {
        case "mov":
            return ("mov", .mov)
        case "m4v":
            return ("m4v", .m4v)
        case "mp4":
            fallthrough
        default:
            return ("mp4", .mp4)
        }
    }

    private static func mergeAudioWithVideo(videoURL: URL, audioURL: URL, outputFileType: AVFileType, completion: @escaping (URL?) -> Void) {
        let mixComposition = AVMutableComposition()
        
        let videoAsset = AVAsset(url: videoURL)
        let audioAsset = AVAsset(url: audioURL)
        
        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first,
              let audioTrack = audioAsset.tracks(withMediaType: .audio).first else {
            completion(nil)
            return
        }
        
        guard let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
              let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(nil)
            return
        }
        
        do {
            try compositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration),
                                                      of: videoTrack,
                                                      at: .zero)
            try compositionAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: audioAsset.duration),
                                                      of: audioTrack,
                                                      at: .zero)
        } catch {
            print("Failed to insert tracks: \(error)")
            completion(nil)
            return
        }
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "." + outputFileType.fileExtension)
        
        guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = outputFileType
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    completion(outputURL)
                default:
                    print("Export failed: \(exportSession.error?.localizedDescription ?? "unknown error")")
                    completion(nil)
                }
            }
        }
    }

    private static func getAudioDuration(url: URL) -> Double {
        let asset = AVAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }

    private static func createPixelBuffer(size: CGSize, color: UIColor) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        if let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }

    private static func mergeAudioWithVideo(videoURL: URL, audioURL: URL, completion: @escaping (URL?) -> Void) {
        let mixComposition = AVMutableComposition()

        let videoAsset = AVAsset(url: videoURL)
        let audioAsset = AVAsset(url: audioURL)

        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first,
              let audioTrack = audioAsset.tracks(withMediaType: .audio).first else {
            completion(nil)
            return
        }

        guard let compositionVideoTrack = mixComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ),
        let compositionAudioTrack = mixComposition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            completion(nil)
            return
        }

        do {
            try compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: videoAsset.duration),
                of: videoTrack,
                at: .zero
            )

            try compositionAudioTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: audioAsset.duration),
                of: audioTrack,
                at: .zero
            )
        } catch {
            print("Failed to insert tracks: \(error)")
            completion(nil)
            return
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")

        guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true

        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    completion(outputURL)
                default:
                    print("Export failed: \(exportSession.error?.localizedDescription ?? "unknown error")")
                    completion(nil)
                }
            }
        }
    }
}

//
//  AudioToVideoConverter.swift
//  AudioConverter
//
//  Created by Max on 02.07.2025.
//

import Foundation
import AVFoundation

enum AudioToVideoConverter {
    static func convert(audioURL: URL, format: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let composition = AVMutableComposition()
        guard let audioAsset = try? AVURLAsset(url: audioURL),
              let audioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
              ) else {
            completion(.failure(NSError(domain: "Invalid audio", code: -1)))
            return
        }
        
        do {
            try audioTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: audioAsset.duration),
                of: audioAsset.tracks(withMediaType: .audio).first!,
                at: .zero
            )
        } catch {
            completion(.failure(error))
            return
        }
        
        let size = CGSize(width: 1080, height: 1080)
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".mp4")
        
        guard let writer = try? AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(.failure(NSError(domain: "Export session error", code: -2)))
            return
        }

        writer.outputURL = outputURL
        writer.outputFileType = .mp4
        writer.shouldOptimizeForNetworkUse = true

        writer.exportAsynchronously {
            if writer.status == .completed {
                completion(.success(outputURL))
            } else {
                completion(.failure(writer.error ?? NSError(domain: "Export failed", code: -3)))
            }
        }
    }
}

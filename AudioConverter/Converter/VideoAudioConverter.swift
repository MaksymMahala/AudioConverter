//
//  VideoAudioConverter.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import AVFoundation

struct VideoAudioConverter {
    static func extractAudio(from videoURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let asset = AVAsset(url: videoURL)
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            completion(.failure(NSError(domain: "No audio track found", code: 0)))
            return
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("convertedAudio.m4a")

        do {
            if FileManager.default.fileExists(atPath: outputURL.path) {
                try FileManager.default.removeItem(at: outputURL)
            }

            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
                completion(.failure(NSError(domain: "Export session failed", code: 1)))
                return
            }

            exportSession.outputURL = outputURL
            exportSession.outputFileType = .m4a
            exportSession.exportAsynchronously {
                if exportSession.status == .completed {
                    completion(.success(outputURL))
                } else {
                    completion(.failure(exportSession.error ?? NSError(domain: "Unknown export error", code: 2)))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}

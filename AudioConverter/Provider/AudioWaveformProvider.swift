//
//  AudioWaveformProvider.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import AVFoundation
import Accelerate

final class AudioWaveformProvider {
    static func extractAmplitudes(from url: URL, sampleCount: Int = 300) async -> [CGFloat] {
        let asset = AVAsset(url: url)
        
        do {
            let tracks = try await asset.loadTracks(withMediaType: .audio)
            guard let track = tracks.first else { return [] }

            let readerSettings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVLinearPCMIsFloatKey: true,
                AVLinearPCMBitDepthKey: 32,
                AVLinearPCMIsNonInterleaved: false
            ]

            guard let reader = try? AVAssetReader(asset: asset) else { return [] }

            let output = AVAssetReaderTrackOutput(track: track, outputSettings: readerSettings)
            reader.add(output)
            reader.startReading()

            var amplitudes: [Float] = []
            while let buffer = output.copyNextSampleBuffer(),
                  let blockBuffer = CMSampleBufferGetDataBuffer(buffer) {

                let length = CMBlockBufferGetDataLength(blockBuffer)
                var data = [Float](repeating: 0, count: length / MemoryLayout<Float>.size)
                CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: &data)

                for sample in data {
                    amplitudes.append(abs(sample))
                }
            }

            let downsampled = downsample(amplitudes, to: sampleCount)
            return downsampled.map { CGFloat($0) }

        } catch {
            print("Error loading audio track: \(error)")
            return []
        }
    }

    private static func downsample(_ data: [Float], to size: Int) -> [Float] {
        guard !data.isEmpty, size > 0 else { return [] }
        let chunkSize = data.count / size
        return stride(from: 0, to: data.count, by: chunkSize).map {
            let chunk = data[$0..<min($0 + chunkSize, data.count)]
            return chunk.max() ?? 0
        }
    }
}

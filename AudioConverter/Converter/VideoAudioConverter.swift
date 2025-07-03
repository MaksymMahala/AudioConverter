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
    
    static func convertToWAV(inputURL: URL, outputURL: URL, completion: @escaping (Bool) -> Void) {
        let asset = AVAsset(url: inputURL)
        
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            print("No audio track found")
            completion(false)
            return
        }

        guard let reader = try? AVAssetReader(asset: asset) else {
            print("Failed to create AVAssetReader")
            completion(false)
            return
        }

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]

        let readerOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: settings)
        
        guard reader.canAdd(readerOutput) else {
            print("Cannot add reader output")
            completion(false)
            return
        }
        reader.add(readerOutput)

        guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .wav) else {
            print("Failed to create AVAssetWriter")
            completion(false)
            return
        }

        let writerInput = AVAssetWriterInput(mediaType: .audio, outputSettings: settings)
        writerInput.expectsMediaDataInRealTime = false

        guard writer.canAdd(writerInput) else {
            print("Cannot add writer input")
            completion(false)
            return
        }
        writer.add(writerInput)

        writer.startWriting()
        writer.startSession(atSourceTime: .zero)

        guard reader.startReading() else {
            print("Failed to start reader: \(reader.error?.localizedDescription ?? "Unknown error")")
            completion(false)
            return
        }

        let processingQueue = DispatchQueue(label: "wav.convert.queue")

        writerInput.requestMediaDataWhenReady(on: processingQueue) {
            while writerInput.isReadyForMoreMediaData {
                if reader.status == .reading {
                    if let buffer = readerOutput.copyNextSampleBuffer() {
                        if !writerInput.append(buffer) {
                            print("Failed to append buffer")
                            reader.cancelReading()
                            writerInput.markAsFinished()
                            writer.finishWriting {
                                completion(false)
                            }
                            break
                        }
                    } else {
                        writerInput.markAsFinished()
                        writer.finishWriting {
                            if writer.status == .completed {
                                completion(true)
                            } else {
                                print("Writer error: \(writer.error?.localizedDescription ?? "unknown error")")
                                completion(false)
                            }
                        }
                        break
                    }
                } else {
                    writerInput.markAsFinished()
                    writer.finishWriting {
                        if writer.status == .completed {
                            completion(true)
                        } else {
                            print("Writer error: \(writer.error?.localizedDescription ?? "unknown error")")
                            completion(false)
                        }
                    }
                    break
                }
            }
        }
    }
    
    static func downloadVideo(from url: URL, completion: @escaping (URL?) -> Void) {
        URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            if let tempURL = tempURL {
                let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
                do {
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                    print("✅ Video downloaded to: \(destinationURL)")
                    completion(destinationURL)
                } catch {
                    print("❌ Move error: \(error)")
                    completion(nil)
                }
            } else {
                print("❌ Download error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }.resume()
    }
}

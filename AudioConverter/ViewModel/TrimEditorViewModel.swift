//
//  TrimEditorViewModel.swift
//  AudioConverter
//
//  Created by Max on 04.07.2025.
//

import AVFoundation
import Combine
import SwiftUI
import PhotosUI

class TrimEditorViewModel: ObservableObject {
    //MARK: TRIM
    @Published var timeRangeStart: Double = 0
    @Published var timeRangeEnd: Double = 5
    @Published var isEditingTimeRange = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    @Published var startTime: Double = 0
    @Published var endTime: Double = 5
    
    //MARK: Watermark
    @Published var watermarkImage: UIImage? = nil
    @Published var watermarkOffset: CGSize = .zero
    @Published var dragOffset: CGSize = .zero
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet {
            Task {
                guard let selectedItem else { return }
                if let data = try? await selectedItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        self.watermarkImage = uiImage
                        self.dragOffset = .zero
                        self.watermarkOffset = .zero
                        self.selectedItem = nil
                    }
                }
            }
        }
    }
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private var videoURL: URL?

    func loadVideoInfo(from url: URL) {
        videoURL = url
        setupPlayer(with: url)
    }

    func setupPlayer(with url: URL) {
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        Task {
            do {
                let asset = await playerItem?.asset
                let durationTime = try await asset?.load(.duration)
                await MainActor.run {
                    self.duration = durationTime?.seconds ?? 1
                    self.endTime = self.duration
                }
            } catch {
                print("Failed to load duration: \(error)")
            }
        }

        addPeriodicTimeObserver()
    }
    
    func pausePlayer() {
        player?.pause()
    }

    func getPlayer() -> AVPlayer? {
        return player
    }

    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }

    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func addPeriodicTimeObserver() {
        guard let player = player else { return }
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.2, preferredTimescale: 600), queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }
    
    func saveFileToDB(fileName: String, type: String) {
        let start = CMTime(seconds: timeRangeStart, preferredTimescale: 600)
        let end = CMTime(seconds: timeRangeEnd, preferredTimescale: 600)
        let durationSeconds = CMTimeGetSeconds(end) - CMTimeGetSeconds(start)
        
        exportTrimmedVideo { outputURL in
            if let outputURL = outputURL {
                CoreDataManager.shared.addSavedFile(
                    fileURL: outputURL,
                    fileName: fileName,
                    type: type,
                    fileSize: self.fileSize(fileURL: outputURL),
                    duration: self.formatTime(durationSeconds)
                )
            }
        }
    }
    
    func saveWaterMarkedFileToDB(fileName: String, type: String) {
        let start = CMTime(seconds: timeRangeStart, preferredTimescale: 600)
        let end = CMTime(seconds: timeRangeEnd, preferredTimescale: 600)
        let durationSeconds = CMTimeGetSeconds(end) - CMTimeGetSeconds(start)
        
        exportVideoWithWatermark { outputURL in
            if let outputURL = outputURL {
                CoreDataManager.shared.addSavedFile(
                    fileURL: outputURL,
                    fileName: fileName,
                    type: type,
                    fileSize: self.fileSize(fileURL: outputURL),
                    duration: self.formatTime(durationSeconds)
                )
            }
        }
    }
    
    func fileSize(fileURL: URL) -> UInt64 {
        return (try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? UInt64) ?? 0
    }
    
    func timeString(from seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    func decreaseStartTime(by delta: Double = 0.02) {
        let newValue = max(startTime - delta, 0)
        if newValue < endTime {
            startTime = newValue
            seek(to: newValue)
        }
    }
    
    func increaseStartTime(by delta: Double = 0.02) {
        let newValue = min(startTime + delta, endTime)
        if newValue < endTime {
            startTime = newValue
            seek(to: newValue)
        }
    }
    
    func decreaseEndTime(by delta: Double = 0.02) {
        let newValue = max(endTime - delta, startTime)
        if newValue > startTime {
            endTime = newValue
        }
    }
    
    func increaseEndTime(by delta: Double = 0.02) {
        let newValue = min(endTime + delta, duration)
        if newValue > startTime {
            endTime = newValue
        }
    }
    

    deinit {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
    }
}

extension TrimEditorViewModel {
    private func exportTrimmedVideo(completion: @escaping (URL?) -> Void) {
        guard let videoURL = videoURL else {
            completion(nil)
            return
        }

        let asset = AVAsset(url: videoURL)
        let start = CMTime(seconds: timeRangeStart, preferredTimescale: 600)
        let end = CMTime(seconds: timeRangeEnd, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: start, end: end)

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            print("Failed to create export session")
            completion(nil)
            return
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("trimmed_\(UUID().uuidString).mp4")

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.timeRange = timeRange

        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    print("Export successful: \(outputURL)")
                    completion(outputURL)
                } else {
                    print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                }
            }
        }
    }
    
    private func exportVideoWithWatermark(completion: @escaping (URL?) -> Void) {
        guard let videoURL = videoURL, let watermarkImage = watermarkImage else {
            completion(nil)
            return
        }

        let asset = AVAsset(url: videoURL)
        let mixComposition = AVMutableComposition()
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(nil)
            return
        }
        
        let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        
        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: .video,
                                                                    preferredTrackID: kCMPersistentTrackID_Invalid)
        try? compositionVideoTrack?.insertTimeRange(timeRange,
                                                    of: videoTrack,
                                                    at: .zero)
        compositionVideoTrack?.preferredTransform = videoTrack.preferredTransform
        
        // Create video layer
        let videoSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        let renderSize = CGSize(width: abs(videoSize.width), height: abs(videoSize.height))
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: renderSize)
        videoLayer.frame = CGRect(origin: .zero, size: renderSize)
        parentLayer.addSublayer(videoLayer)
        
        // Add watermark layer
        let watermarkLayer = CALayer()
        watermarkLayer.contents = watermarkImage.cgImage
        watermarkLayer.frame = CGRect(x: renderSize.width / 2 + watermarkOffset.width,
                                      y: renderSize.height / 2 - watermarkOffset.height,
                                      width: 80, height: 80)
        watermarkLayer.masksToBounds = true
        parentLayer.addSublayer(watermarkLayer)
        
        // Add video composition
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = renderSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer,
                                                                              in: parentLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = timeRange
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack!)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        // Export
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("watermarked_\(UUID().uuidString).mp4")
        
        guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    print("Watermarked export success: \(outputURL)")
                    completion(outputURL)
                } else {
                    print("Watermarked export failed: \(exportSession.error?.localizedDescription ?? "unknown error")")
                    completion(nil)
                }
            }
        }
    }
}


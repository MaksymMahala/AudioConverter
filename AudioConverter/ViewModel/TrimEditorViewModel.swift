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
import CoreImage
import CoreImage.CIFilterBuiltins

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
    @Published var setCoverImage: UIImage? = nil
    @Published var isPresentedSetCoverSheet = false
    @Published var isPresentedLoading = false
    @Published var selectedNumberWaterMarks = 0
    @Published var isNumberOfWaterMarkView = false
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
    
    var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    var videoURL: URL?

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
    
    func playPlayer() {
        player?.play()
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
    
    func saveCoveredFileToDB(fileName: String, type: String) async {
        guard let videoURL = self.videoURL else {
            print("No video URL to export")
            return
        }

        let asset = AVAsset(url: videoURL)
        guard let videoTrack = asset.tracks(withMediaType: .video).first,
              let audioTrack = asset.tracks(withMediaType: .audio).first else {
            print("Failed to get video or audio tracks")
            return
        }

        let duration = asset.duration

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")

        try? await exportSetCover(
            videoTrack: videoTrack,
            audioTrack: audioTrack,
            duration: duration,
            coverImage: setCoverImage,
            outputURL: outputURL
        ) { outputURL in
            if let outputURL = outputURL {
                CoreDataManager.shared.addSavedFile(
                    fileURL: outputURL,
                    fileName: fileName,
                    type: type,
                    fileSize: self.fileSize(fileURL: outputURL),
                    duration: self.formatTime(CMTimeGetSeconds(duration))
                )
            } else {
                print("Export failed")
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
    
    func blurAction() {
        isPresentedLoading = true
        guard let playerItem = player?.currentItem else {
            print("Missing player item")
            return
        }
        
        let asset = playerItem.asset
        
        Task {
            do {
                let videoTracks = try await asset.loadTracks(withMediaType: .video)
                guard let videoTrack = videoTracks.first else {
                    print("No video track")
                    isPresentedLoading = false
                    return
                }
                
                let naturalSize = try await videoTrack.load(.naturalSize)
                let preferredTransform = try await videoTrack.load(.preferredTransform)
                let transformedSize = naturalSize.applying(preferredTransform)
                
                let videoWidth = abs(transformedSize.width)
                let videoHeight = abs(transformedSize.height)
                
                let watermarkWidth: CGFloat = 300
                let watermarkHeight: CGFloat = 150
                let spacing: CGFloat = 20
                
                var rects: [CGRect] = []
                
                for i in 0..<max(selectedNumberWaterMarks, 1) {
                    let x = videoWidth - watermarkWidth - spacing
                    let y = videoHeight - watermarkHeight - spacing - CGFloat(i) * (watermarkHeight + spacing)

                    let rawRect = CGRect(x: x, y: y, width: watermarkWidth, height: watermarkHeight)
                    let correctedRect = convertRectToVideoCoordinates(rect: rawRect, videoSize: CGSize(width: videoWidth, height: videoHeight), transform: preferredTransform)
                    
                    if correctedRect.origin.x >= 0,
                       correctedRect.origin.y >= 0,
                       correctedRect.maxX <= videoWidth,
                       correctedRect.maxY <= videoHeight {
                        rects.append(correctedRect)
                    } else {
                        print("⚠️ Skipping rect \(i) — out of bounds after transform")
                    }
                }
                
                exportVideoWithBlurredWatermarkAreas(watermarkRects: rects) { [weak self] outputURL in
                    if let url = outputURL {
                        print("✅ Blurred watermark video saved at: \(url)")
                        DispatchQueue.main.async {
                            guard let self = self else { return }
                            self.loadVideoInfo(from: url)
                            self.playPlayer()
                            self.isPresentedLoading = false
                        }
                    } else {
                        self?.isPresentedLoading = false
                        print("❌ Failed to export video with blurred watermark(s)")
                    }
                }
                
            } catch {
                self.isPresentedLoading = false
                print("❌ Error loading asset data: \(error)")
            }
        }
    }
    
    private func convertRectToVideoCoordinates(rect: CGRect, videoSize: CGSize, transform: CGAffineTransform) -> CGRect {
        let invertedTransform = transform.inverted()
        var transformedRect = rect.applying(invertedTransform)
        
        transformedRect.origin.y = videoSize.height - transformedRect.origin.y - transformedRect.height
        
        return transformedRect
    }
    
    deinit {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
}

extension TrimEditorViewModel {
    private func exportSetCover(
        videoTrack: AVAssetTrack,
        audioTrack: AVAssetTrack,
        duration: CMTime,
        coverImage: UIImage?,
        outputURL: URL,
        completion: @escaping (URL?) -> Void
    ) async throws {
        let mixComposition = AVMutableComposition()

        guard let videoCompositionTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
              let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(nil)
            return
        }

        try videoCompositionTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: duration), of: videoTrack, at: .zero)
        try audioCompositionTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: duration), of: audioTrack, at: .zero)

        guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true

        if let coverImage = coverImage {
            let size = videoTrack.naturalSize

            let imageLayer = CALayer()
            imageLayer.contents = coverImage.cgImage
            imageLayer.frame = CGRect(origin: .zero, size: size)
            imageLayer.opacity = 1.0

            let videoLayer = CALayer()
            videoLayer.frame = CGRect(origin: .zero, size: size)

            let parentLayer = CALayer()
            parentLayer.frame = CGRect(origin: .zero, size: size)
            parentLayer.addSublayer(videoLayer)
            parentLayer.addSublayer(imageLayer)

            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: .zero, duration: duration)

            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
            instruction.layerInstructions = [layerInstruction]

            let videoComposition = AVMutableVideoComposition()
            videoComposition.instructions = [instruction]
            videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
            videoComposition.renderSize = size
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
                postProcessingAsVideoLayer: videoLayer,
                in: parentLayer
            )

            exportSession.videoComposition = videoComposition
        }

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(outputURL)
            case .failed:
                print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            case .cancelled:
                print("Export cancelled")
                completion(nil)
            default:
                print("Export status: \(exportSession.status)")
                completion(nil)
            }
        }
    }


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
        
        let videoSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        let renderSize = CGSize(width: abs(videoSize.width), height: abs(videoSize.height))
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: renderSize)
        videoLayer.frame = CGRect(origin: .zero, size: renderSize)
        parentLayer.addSublayer(videoLayer)
        
        let watermarkLayer = CALayer()
        watermarkLayer.contents = watermarkImage.cgImage
        watermarkLayer.frame = CGRect(x: renderSize.width / 2 + watermarkOffset.width,
                                      y: renderSize.height / 2 - watermarkOffset.height,
                                      width: 80, height: 80)
        watermarkLayer.masksToBounds = true
        parentLayer.addSublayer(watermarkLayer)
        
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
    
    private func exportVideoWithBlurredWatermarkAreas(watermarkRects: [CGRect], completion: @escaping (URL?) -> Void) {
        guard let videoURL = videoURL else {
            completion(nil)
            return
        }
        
        let asset = AVAsset(url: videoURL)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(nil)
            return
        }
        
        let composition = AVMutableComposition()
        guard let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(nil)
            return
        }
        
        do {
            try compositionTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: videoTrack, at: .zero)
        } catch {
            print("Failed to insert time range: \(error)")
            completion(nil)
            return
        }
        
        compositionTrack.preferredTransform = videoTrack.preferredTransform
        
        let videoSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        let renderSize = CGSize(width: abs(videoSize.width), height: abs(videoSize.height))
        
        let videoComposition = AVMutableVideoComposition(asset: asset) { request in
            let sourceImage = request.sourceImage.clampedToExtent()
            
            guard let blurFilter = CIFilter(name: "CIGaussianBlur") else {
                request.finish(with: sourceImage, context: nil)
                return
            }
            
            blurFilter.setValue(sourceImage, forKey: kCIInputImageKey)
            blurFilter.setValue(15.0, forKey: kCIInputRadiusKey)
            
            guard let blurredImage = blurFilter.outputImage else {
                request.finish(with: sourceImage, context: nil)
                return
            }
            
            let extent = sourceImage.extent
            var maskImage = CIImage(color: .clear).cropped(to: extent)
            
            for rect in watermarkRects {
                // Використовуємо rect без додаткових змін, бо вони вже конвертовані
                let ciRect = rect
                
                guard ciRect.origin.x >= 0,
                      ciRect.origin.y >= 0,
                      ciRect.maxX <= extent.width,
                      ciRect.maxY <= extent.height else {
                    print("⚠️ Skipping out-of-bounds rect: \(ciRect)")
                    continue
                }
                
                let whiteMask = CIImage(color: .white).cropped(to: ciRect)
                maskImage = whiteMask.composited(over: maskImage)
            }
            
            guard let blend = CIFilter(name: "CIBlendWithMask") else {
                request.finish(with: sourceImage, context: nil)
                return
            }
            
            blend.setValue(blurredImage, forKey: kCIInputImageKey)
            blend.setValue(sourceImage, forKey: kCIInputBackgroundImageKey)
            blend.setValue(maskImage, forKey: kCIInputMaskImageKey)
            
            if let output = blend.outputImage?.cropped(to: extent) {
                request.finish(with: output, context: nil)
            } else {
                request.finish(with: sourceImage, context: nil)
            }
        }
        
        videoComposition.renderSize = renderSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("blurred_\(UUID().uuidString).mp4")
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    print("✅ Exported to \(outputURL)")
                    completion(outputURL)
                } else {
                    print("❌ Export failed: \(exportSession.error?.localizedDescription ?? "unknown error")")
                    completion(nil)
                }
            }
        }
    }
}


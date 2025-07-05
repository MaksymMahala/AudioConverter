//
//  CutVideoEditorViewModel.swift
//  AudioConverter
//
//  Created by Max on 04.07.2025.
//

import AVFoundation
import Combine

class CutVideoEditorViewModel: ObservableObject {
    @Published var openResolution = false
    @Published var selectedResolution: ResolutionOption? {
        didSet {
            if let url = videoURL {
                setupPlayer(with: url)
            }
        }
    }
    
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    @Published var startTime: Double = 0
    @Published var endTime: Double = 5
    @Published var hasProAccess = false
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private var videoURL: URL?

    func loadVideoInfo(from url: URL) {
        videoURL = url
        setupPlayer(with: url)

        let asset = AVAsset(url: url)
        Task {
            do {
                let tracks = try await asset.loadTracks(withMediaType: .video)
                if let track = tracks.first {
                    let size = try await track.load(.naturalSize)
                    let transform = try await track.load(.preferredTransform)
                    let fixedSize = size.applying(transform)
                    await MainActor.run {
                        self.selectedResolution = ResolutionOption(
                            value: "\(Int(abs(fixedSize.width)))x\(Int(abs(fixedSize.height)))",
                            isPro: false
                        )
                    }
                }
            } catch {
                print("Failed to load resolution: \(error)")
            }
        }
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
    
    private func exportTrimmedVideo(completion: @escaping (URL?) -> Void) {
        guard let videoURL = videoURL else {
            completion(nil)
            return
        }

        let asset = AVAsset(url: videoURL)
        let start = CMTime(seconds: startTime, preferredTimescale: 600)
        let end = CMTime(seconds: endTime, preferredTimescale: 600)
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
    
    func saveFileToDB(fileName: String, type: String) {
        exportTrimmedVideo { outputURL in
            guard let outputURL = outputURL else { return }
            
            let durationSeconds = self.endTime - self.startTime
            
            CoreDataManager.shared.addSavedFile(
                fileURL: outputURL,
                fileName: fileName,
                type: type,
                fileSize: self.fileSize(fileURL: outputURL),
                duration: self.formatTime(durationSeconds)
            )
        }
    }
    
    func fileSize(fileURL: URL) -> UInt64 {
        return (try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? UInt64) ?? 0
    }

    deinit {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
    }
}

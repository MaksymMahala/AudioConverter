//
//  PlayerViewModel.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import AVFoundation
import Combine
import UniformTypeIdentifiers
import PDFKit
import ImageIO
import CoreImage

final class PlayerViewModel: ObservableObject {
    @Published var currentTime: Double = 0
    @Published var isPlaying: Bool = false
    @Published var duration: Double?
    @Published var timeRangeStart: Double = 0
    @Published var timeRangeEnd: Double = 5
    @Published var currentEffect: String? = nil
    @Published var waveform: [CGFloat] = []
    
    //MARK: Formats
    @Published var selectedFormat: String = "MP3"
    @Published var selectedTab = "Editing"
    @Published var fileType: FileType = .audio
      
    let availableAudioFormats = ["CAF", "MP3", "M4F", "WAV 44100"]
    let availableVideoFormats = ["MP4", "MOV", "M4V"]
    let availableImageFormats = ["PDF", "JPG", "WEBP", "HEIC", "GIF"]
    
    var availableFormats: [String] {
        switch fileType {
        case .audio:
            return availableVideoFormats
        case .video:
            return availableAudioFormats
        case .image:
            return availableImageFormats
        }
    }

    //MARK: Audio
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let reverb = AVAudioUnitReverb()
    private let eq = AVAudioUnitEQ(numberOfBands: 2)

    var audioFile: AVAudioFile?
    private var timeObserver: Any?
    private var timer: Timer?

    let effects = ["Noise", "Echo", "Bass", "Reverb", "Cut"]

    func load(url: URL) {
        stop()

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }

        do {
            audioFile = try AVAudioFile(forReading: url)
        } catch {
            print("Failed to load audio file: \(error)")
            return
        }

        setupAudioEngine()

        duration = audioFile != nil ? audioFile!.length.toSeconds(sampleRate: audioFile!.processingFormat.sampleRate) : nil
        timeRangeStart = 0
        timeRangeEnd = min(5.0, self.duration ?? 5.0)
        currentTime = 0
    }

    private func setupAudioEngine() {
        engine.stop()
        engine.reset()

        engine.attach(playerNode)
        engine.attach(reverb)
        engine.attach(eq)

        engine.connect(playerNode, to: eq, format: audioFile?.processingFormat)
        engine.connect(eq, to: reverb, format: audioFile?.processingFormat)
        engine.connect(reverb, to: engine.mainMixerNode, format: audioFile?.processingFormat)

        reverb.loadFactoryPreset(.mediumRoom)
        reverb.wetDryMix = 50

        eq.bands[0].filterType = .lowShelf
        eq.bands[0].frequency = 100
        eq.bands[0].gain = 5
        eq.bands[0].bypass = false

        eq.bands[1].filterType = .highShelf
        eq.bands[1].frequency = 10000
        eq.bands[1].gain = -5
        eq.bands[1].bypass = false

        do {
            try engine.start()
        } catch {
            print("Error starting engine: \(error)")
        }
    }

    func togglePlayPause() {
        guard let file = audioFile else { return }

        if isPlaying {
            playerNode.pause()
            isPlaying = false
            stopTimer()
        } else {
            if !playerNode.isPlaying {
                playerNode.scheduleFile(file, at: nil)
            }
            playerNode.play()
            isPlaying = true
            startTimer()
        }
    }

    func seek(to seconds: Double) {
        guard let file = audioFile else { return }

        playerNode.stop()
        currentTime = seconds

        let sampleRate = file.processingFormat.sampleRate
        let framePosition = AVAudioFramePosition(seconds * sampleRate)
        let framesCount = file.length - framePosition

        guard framesCount > 0 else { return }

        do {
            try engine.start()
        } catch {
            print("Error starting engine: \(error)")
        }

        playerNode.scheduleSegment(file,
                                   startingFrame: framePosition,
                                   frameCount: AVAudioFrameCount(framesCount),
                                   at: nil)
        playerNode.play()
        isPlaying = true
        startTimer()
    }
    
    func seek(by seconds: Double) {
        guard let duration = duration else { return }
        var newTime = currentTime + seconds
        newTime = min(max(newTime, 0), duration)
        seek(to: newTime)
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime += 0.2
            if let duration = self.duration, self.currentTime >= duration {
                self.currentTime = duration
                self.isPlaying = false
                self.playerNode.stop()
                self.stopTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func applyEffect(_ effectName: String?) {
        currentEffect = effectName
        switch effectName {
        case "Reverb":
            reverb.wetDryMix = 80
        case "Echo":
            reverb.wetDryMix = 50
        case "Cut":
            eq.bands[0].gain = -20
        case "Bass":
            eq.bands[0].gain = 10
        case "Noise":
            break
        default:
            reverb.wetDryMix = 0
            eq.bands[0].gain = 0
        }
    }

    func stop() {
        playerNode.stop()
        stopTimer()
        engine.stop()
        isPlaying = false
        currentTime = 0
    }
    
    func formatTime(_ time: Double) -> String {
        guard time.isFinite else { return "00:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func formatedTime(_ time: Double?) -> String {
        guard let time = time else { return "00:00" }
        guard time.isFinite else { return "00:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func saveConvertedFileToDB(url: URL, fileName: String, type: String) {
        CoreDataManager.shared.addSavedFile(fileURL: url, fileName: fileName, type: type, fileSize: fileSize(fileURL: url), duration: formatedTime(duration))
    }
    
    func saveConvertedImageToDB(url: URL, fileName: String, type: String, selectedImage: UIImage?) {
        CoreDataManager.shared.addSavedFile(fileURL: url, fileName: fileName, type: type, fileSize: fileSize(fileURL: url), duration: formatedTime(duration), image: selectedImage, imageFileExtension: selectedFormat)
    }
    
    func saveEditedImageToDB(fileName: String, type: String, selectedImage: UIImage?) {
        guard let image = selectedImage else {
            print("No image to save")
            return
        }
        
        let imageData = image.jpegData(compressionQuality: 1.0)
        let fileSizeValue = UInt64(imageData?.count ?? 0)
        
        CoreDataManager.shared.addSavedFile(
            fileURL: URL(fileURLWithPath: ""),
            fileName: fileName,
            type: type,
            fileSize: fileSizeValue,
            duration: "N/A",
            image: image,
            imageFileExtension: selectedFormat.lowercased()
        )
    }

    
    func fileSize(fileURL: URL) -> UInt64 {
        if let fileSize = try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? UInt64 {
            return fileSize
        }
        
        return UInt64()
    }

    deinit {
        stop()
    }
}

extension PlayerViewModel {
    func convertToAudio(originalAudioURL: URL, completion: @escaping (URL?) -> Void) {
        let ext: String
        let preset: String

        switch selectedFormat {
        case "CAF":
            ext = "caf"
            preset = AVAssetExportPresetPassthrough
        case "M4F":
            ext = "m4a"
            preset = AVAssetExportPresetAppleM4A
        case "WAV 44100":
            let ext = "wav"
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "." + ext)
            VideoAudioConverter.convertToWAV(inputURL: originalAudioURL, outputURL: outputURL) { success in
                DispatchQueue.main.async {
                    if success {
                        completion(outputURL)
                    } else {
                        print("WAV export failed")
                        completion(nil)
                    }
                }
            }
            return
        case "MP3":
            exportMP3(from: originalAudioURL) { mp3URL in
                DispatchQueue.main.async {
                    if let mp3URL = mp3URL {
                        completion(mp3URL)
                    } else {
                        print("MP3 export failed")
                        completion(nil)
                    }
                }
            }
            return
        default:
            ext = "m4a"
            preset = AVAssetExportPresetAppleM4A
        }

        let asset = AVURLAsset(url: originalAudioURL)

        guard asset.tracks(withMediaType: .audio).first != nil else {
            print("❌ No audio track found in the original file")
            completion(nil)
            return
        }

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: preset) else {
            print("❌ Could not create export session")
            completion(nil)
            return
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "." + ext)

        exportSession.outputURL = outputURL
        exportSession.outputFileType = fileType(forExtension: ext)
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.timeRange = CMTimeRange(start: .zero, duration: asset.duration) // ✅ додаємо

        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    print("✅ Exported to: \(outputURL)")
                    completion(outputURL)
                case .failed, .cancelled:
                    print("❌ Export failed: \(exportSession.error?.localizedDescription ?? "unknown error")")
                    completion(nil)
                default:
                    completion(nil)
                }
            }
        }
    }

    private func fileType(forExtension ext: String) -> AVFileType {
        switch ext.lowercased() {
        case "caf": return .caf
        case "m4a": return .m4a
        case "wav": return .wav
        default: return .m4a
        }
    }
    
    func exportMP3(from originalAudioURL: URL, completion: @escaping (URL?) -> Void) {
        let wavURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".wav")
        
        VideoAudioConverter.convertToWAV(inputURL: originalAudioURL, outputURL: wavURL) { success in
            guard success else {
                print("❌ WAV conversion failed")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let mp3URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp3")
            
            DispatchQueue.global(qos: .userInitiated).async {
                let success = MP3Encoder.convertPCMtoMP3(pcmURL: wavURL, mp3URL: mp3URL)
                
                DispatchQueue.main.async {
                    if success {
                        print("✅ MP3 export succeeded at: \(mp3URL)")
                        completion(mp3URL)
                    } else {
                        print("❌ MP3 export failed")
                        completion(nil)
                    }
                }
            }
        }
    }
}

extension PlayerViewModel {
    func convertToImageFormat(inputURL: URL, completion: @escaping (URL?) -> Void) {
        guard let inputImage = UIImage(contentsOfFile: inputURL.path) else {
            print("Failed to load image from path.")
            completion(nil)
            return
        }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(selectedFormat.lowercased())

        switch selectedFormat {
        case "JPG":
            guard let data = inputImage.jpegData(compressionQuality: 1.0) else {
                completion(nil)
                return
            }
            do {
                try data.write(to: outputURL)
                completion(outputURL)
            } catch {
                print("Failed to write JPG: \(error)")
                completion(nil)
            }

        case "PDF":
            let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: inputImage.size))
            do {
                try pdfRenderer.writePDF(to: outputURL) { context in
                    context.beginPage()
                    inputImage.draw(in: CGRect(origin: .zero, size: inputImage.size))
                }
                completion(outputURL)
            } catch {
                print("Failed to write PDF: \(error)")
                completion(nil)
            }

        case "HEIC":
            guard let cgImage = inputImage.cgImage else {
                completion(nil)
                return
            }

            let dest = CGImageDestinationCreateWithURL(outputURL as CFURL, AVFileType.heic as CFString, 1, nil)
            if let dest = dest {
                CGImageDestinationAddImage(dest, cgImage, nil)
                if CGImageDestinationFinalize(dest) {
                    completion(outputURL)
                } else {
                    print("Failed to finalize HEIC")
                    completion(nil)
                }
            } else {
                print("Failed to create destination for HEIC")
                completion(nil)
            }

        case "GIF":
            guard let imageData = inputImage.pngData() else {
                completion(nil)
                return
            }
            do {
                try imageData.write(to: outputURL)
                completion(outputURL)
            } catch {
                print("Failed to write GIF (as PNG fallback): \(error)")
                completion(nil)
            }

        case "WEBP":
            WebpCoder.exportToWebP(image: inputImage) { url in
                completion(url)
            }
        default:
            print("Unsupported format: \(selectedFormat)")
            completion(nil)
        }
    }
}

extension PlayerViewModel {
    func exportTrimmedAudio(from originalURL: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: originalURL)
        
        let startTime = CMTime(seconds: timeRangeStart, preferredTimescale: 600)
        let endTime = CMTime(seconds: timeRangeEnd, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: startTime, end: endTime)

        let composition = AVMutableComposition()
        
        guard let assetTrack = asset.tracks(withMediaType: .audio).first,
              let compTrack = composition.addMutableTrack(withMediaType: .audio,
                                                           preferredTrackID: kCMPersistentTrackID_Invalid) else {
            print("Failed to get audio track.")
            completion(nil)
            return
        }

        do {
            try compTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
        } catch {
            print("Failed to insert time range: \(error)")
            completion(nil)
            return
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("trimmed.m4a")

        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }

        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) else {
            print("Failed to create export session.")
            completion(nil)
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        exportSession.timeRange = CMTimeRange(start: .zero, duration: timeRange.duration)

        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    print("Trimmed audio exported to: \(outputURL)")
                    completion(outputURL)
                } else {
                    print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                }
            }
        }
    }
}

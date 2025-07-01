//
//  PlayerViewModel.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import AVFoundation
import Combine

final class PlayerViewModel: ObservableObject {
    @Published var currentTime: Double = 0
    @Published var isPlaying: Bool = false
    @Published var duration: Double?
    @Published var currentEffect: String? = nil
    @Published var selectedTab = "Editing"
    @Published var waveform: [CGFloat] = []
    
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let reverb = AVAudioUnitReverb()
    private let eq = AVAudioUnitEQ(numberOfBands: 2)

    private var audioFile: AVAudioFile?
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

    deinit {
        stop()
    }
}

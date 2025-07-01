//
//  AVAudioFramePosition.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import Foundation
import AVFAudio

extension AVAudioFramePosition {
    func toSeconds(sampleRate: Double) -> Double {
        return Double(self) / sampleRate
    }
}

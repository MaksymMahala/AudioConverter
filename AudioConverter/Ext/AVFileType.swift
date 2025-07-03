//
//  AVFileType.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import AVFoundation

extension AVFileType {
    var fileExtension: String {
        switch self {
        case .mov: return "mov"
        case .mp4: return "mp4"
        case .m4v: return "m4v"
        default: return "mp4"
        }
    }
}

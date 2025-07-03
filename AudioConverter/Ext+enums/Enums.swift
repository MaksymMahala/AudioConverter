//
//  Enums.swift
//  AudioConverter
//
//  Created by Max on 02.07.2025.
//

import Foundation

enum FileType {
    case audio
    case video
    case image
}

enum ImageAction {
    case convert, edit, gif
}

enum AudioAction {
    case convert, trim, createMelody
}

enum VideoAction {
    case convert, videoToAudio, trim, cut, compress, waterMark, setCover
}



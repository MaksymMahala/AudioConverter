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
    case convert, trim, createMelody, edit
}

enum VideoAction {
    case convert, videoToAudio, trim, cut, compress, delete
}

enum VideoAdditionalAction {
    case waterMark, setCover
}

enum WorksAlertType: Identifiable {
    case deleteFile
    case newPlaylist

    var id: Int {
        switch self {
        case .deleteFile: return 0
        case .newPlaylist: return 1
        }
    }
}




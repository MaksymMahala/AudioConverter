//
//  AudioConversionViewModel.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import Foundation
import SwiftUI
import PhotosUI

final class AudioConversionViewModel: ObservableObject {
    //MARK: items
    @Published var tools: [ToolItem] = [
        ToolItem(title: "Audio conversion", subtitle: "AAC, MP3, FLAC, MP2, AMR, OPUS, SWF, WM...", iconName: "iconoir_refresh-double_pink"),
        ToolItem(title: "Create a melody", subtitle: "Create a custom phone call", iconName: "iconoir_music-double-note_pink"),
        ToolItem(title: "Trim audio", subtitle: "Trim in milliseconds", iconName: "iconoir_cut_pink"),
        ToolItem(title: "Edit Audio", subtitle: "", iconName: "iconoir_expand-lines_pink")
    ]
    
    @Published var isDrivePickerPresented = false
    @Published var isDocumentPickerPresented = false
    @Published var openAudioView = false
    
    @Published var audioAction: AudioAction = .convert

    @Published var audioURL: URL?
    @Published var errorMessage: String?
    
    @Published var isEditorPresented = false
}

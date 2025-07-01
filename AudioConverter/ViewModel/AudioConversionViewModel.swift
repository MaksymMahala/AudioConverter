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
        ToolItem(title: "Compress video", subtitle: "Change the bitrate without losing quality", iconName: "iconoir_expand-lines_pink")
    ]
    
    @Published var bottomTool: ToolItem = ToolItem(title: "Edit an audio", subtitle: "", iconName: "iconoir_edit-pencil")
}

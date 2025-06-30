//
//  VideoToolsViewModel.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import Foundation

final class VideoToolsViewModel: ObservableObject {
    @Published var tools: [ToolItem] = [
        ToolItem(title: "Convert video", subtitle: "Support for exports mp3, mp4, aac, aiff...", iconName: "iconoir_refresh-blue"),
        ToolItem(title: "Video to audio", subtitle: "Extract audio mp3, mp4, aac, aiff, ogg", iconName: "iconoir_media-video-list"),
        ToolItem(title: "Trim video", subtitle: "Trim in milliseconds", iconName: "iconoir_cut"),
        ToolItem(title: "Cut video", subtitle: "Cutting video image", iconName: "iconoir_crop"),
        ToolItem(title: "Compress video", subtitle: "Change the bitrate without losing quality", iconName: "iconoir_expand-lines"),
        ToolItem(title: "Delete a video", subtitle: "Remove an unwanted object from a video", iconName: "iconoir_erase")
    ]
    
    @Published var toolsHorizontal: [ToolItem] = [
        ToolItem(title: "Watermark", subtitle: "", iconName: "iconoir_text-square"),
        ToolItem(title: "Set cover", subtitle: "", iconName: "iconoir_bookmark-book")
    ]
}

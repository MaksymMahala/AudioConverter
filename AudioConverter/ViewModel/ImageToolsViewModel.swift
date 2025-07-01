//
//  ImageToolsViewModel.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import Foundation

final class ImageToolsViewModel: ObservableObject {
    @Published var tools: [ToolItem] = [
        ToolItem(title: "Convert images", subtitle: "jpg, png, webp, heic", iconName: "iconoir_refresh-double_purple"),
        ToolItem(title: "Creating GIF files", subtitle: "Extract audio mp3, mp4, off, aac, aiff, ogg", iconName: "iconoir_gif-format")
    ]
    
    @Published var bottomTool: ToolItem = ToolItem(title: "Edit an image", subtitle: "", iconName: "iconoir_edit-pencil_purple")
}

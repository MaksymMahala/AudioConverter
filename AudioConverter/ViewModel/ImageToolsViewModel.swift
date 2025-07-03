//
//  ImageToolsViewModel.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

final class ImageToolsViewModel: ObservableObject {
    @Published var tools: [ToolItem] = [
        ToolItem(title: "Convert images", subtitle: "jpg, png, webp, heic", iconName: "iconoir_refresh-double_purple"),
        ToolItem(title: "Creating GIF files", subtitle: "Extract audio mp3, mp4, off, aac, aiff, ogg", iconName: "iconoir_gif-format")
    ]
    
    @Published var bottomTool: ToolItem = ToolItem(title: "Edit an image", subtitle: "", iconName: "iconoir_edit-pencil_purple")
    @Published var isDrivePickerPresented = false
    @Published var isDocumentPickerPresented = false
    @Published var openImageView = false
    @Published var openEditImageEditor = false
    @Published var isEditorPresented = false
    @Published var isCameraPresented = false
    @Published var isImagePickerPresented = false
    
    @Published var imageURL: URL?
    @Published var selectedImage: UIImage?

    @Published var errorMessage: String?
    @Published var imageAction: ImageAction = .convert

}

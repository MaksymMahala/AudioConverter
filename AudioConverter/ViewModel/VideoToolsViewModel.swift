//
//  VideoToolsViewModel.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import Foundation
import SwiftUI

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
    
    @Published var inputLink: String = ""
    @Published var isDrivePickerPresented = false
    @Published var isDocumentPickerPresented = false
    @Published var videoURL: URL?
    @Published var openAudioView = false
    @Published var isEditorPresented = false
    @Published var isLinkValid: Bool = false
    @Published var isCameraPresented = false

    @Published var isVideoPickerPresented = false
    @Published var errorMessage: String?
    
    func validateLink(isLoadingVideo: Binding<Bool>, dismiss: @escaping () -> ()) {
        guard let url = URL(string: inputLink),
              url.scheme?.starts(with: "http") == true else {
            print("❌ Invalid URL format")
            isLinkValid = false
            return
        }

        isLoadingVideo.wrappedValue = true

        let videoExtensions = ["mp4", "mov", "m4v"]
        let fileExtension = url.pathExtension.lowercased()

        let proceedToDownload: () -> Void = {
            VideoAudioConverter.downloadVideo(from: url) { localURL in
                DispatchQueue.main.async {
                    isLoadingVideo.wrappedValue = false
                    guard let localURL = localURL else {
                        print("❌ Failed to download video")
                        self.isLinkValid = false
                        return
                    }

                    self.videoURL = localURL
                    self.isLinkValid = true
                    self.isEditorPresented = true
                    dismiss()
                }
            }
        }

        if videoExtensions.contains(fileExtension) {
            isLoadingVideo.wrappedValue =  true
            dismiss()
            proceedToDownload()
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoadingVideo.wrappedValue = false
                    self.isLinkValid = false
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No HTTP response")
                DispatchQueue.main.async {
                    isLoadingVideo.wrappedValue = false
                    self.isLinkValid = false
                }
                return
            }

            if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type"),
               contentType.starts(with: "video/") {
                proceedToDownload()
            } else {
                print("❌ Not a video")
                DispatchQueue.main.async {
                    isLoadingVideo.wrappedValue = false
                    self.isLinkValid = false
                }
            }

        }.resume()
    }
}

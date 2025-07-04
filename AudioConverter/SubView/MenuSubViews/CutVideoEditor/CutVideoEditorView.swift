//
//  CutVideoEditorView.swift
//  AudioConverter
//
//  Created by Max on 04.07.2025.
//

import SwiftUI
import AVFoundation
import AVKit

struct CutVideoEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CutVideoEditorViewModel
    @Binding var isLoading: Bool
    let videoURL: URL?
    
    init(isLoading: Binding<Bool>, videoURL: URL?) {
        _viewModel = StateObject(wrappedValue: CutVideoEditorViewModel())
        _isLoading = isLoading
        self.videoURL = videoURL
    }
    var body: some View {
        VStack {
            header
            video
            slider
            resolution
            
            Spacer()
        }
        .onAppear {
            isLoading = false
            if let videoURL = videoURL {
                viewModel.loadVideoInfo(from: videoURL)
            }
        }
        .sheet(isPresented: $viewModel.openResolution) {
            ResolutionPickerView(
                selectedResolution: $viewModel.selectedResolution,
                originalResolution: viewModel.selectedResolution ?? ResolutionOption(size: CGSize(width: 480, height: 720))
            )
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(Font.custom(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            Spacer()
            Text("Cut video")
                .foregroundStyle(Color.black)
                .font(Font.custom(size: 16, weight: .bold))
            Spacer()
            Button("Done") {
                if let videoURL = videoURL {
                    viewModel.saveFileToDB(url: videoURL, fileName: videoURL.absoluteString, type: "Video")
                    dismiss()
                }
            }
            .font(Font.custom(size: 16, weight: .bold))
            .foregroundColor(.black)
        }
        .padding()
    }
    
    @ViewBuilder
    private var video: some View {
        if let player = viewModel.getPlayer(), let resolution = viewModel.selectedResolution {
            let maxHeight: CGFloat = 320
            let scaleFactor = maxHeight / resolution.size.height
            
            VideoPlayer(player: player)
                .frame(width: resolution.size.width * scaleFactor, height: maxHeight)
                .cornerRadius(16)
                .padding(.horizontal)
        } else {
            Color.clear.frame(height: 220).padding(.horizontal)
        }
    }
    
    private var slider: some View {
        VStack {
            let duration = viewModel.duration

            let binding = Binding<Double>(
                get: { viewModel.currentTime },
                set: { newValue in
                    viewModel.currentTime = newValue
                    viewModel.seek(to: newValue)
                }
            )

            Slider(
                value: binding,
                in: 0...duration,
                onEditingChanged: { editing in
                    if !editing {
                        viewModel.seek(to: viewModel.currentTime)
                    }
                }
            )
            .accentColor(.darkBlueD90)
            .padding(.horizontal, 10)

            HStack {
                Text(viewModel.formatTime(viewModel.currentTime))
                Spacer()
                Text(viewModel.formatTime(duration))
            }
            .font(Font.custom(size: 14, weight: .regular))
            .foregroundColor(.gray)
            .padding(.horizontal)
        }
    }
    
    private var resolution: some View {
        settingRow(title: "Resolution", value: viewModel.selectedResolution?.value ?? "") {
            viewModel.pausePlayer()
            viewModel.openResolution = true
        }
        .padding()
    }
    
    private func settingRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(Font.custom(size: 16, weight: .regular))
                    .foregroundColor(.gray50)
                Spacer()
                Text(value)
                    .foregroundColor(.gray50)
                    .font(Font.custom(size: 16, weight: .regular))

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    CutVideoEditorView(isLoading: .constant(false), videoURL: URL(string: "video.mp4"))
}

//
//  WatermarkEditorView.swift
//  AudioConverter
//
//  Created by Max on 04.07.2025.
//

import SwiftUI
import AVKit
import PhotosUI

struct WatermarkEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TrimEditorViewModel
    @Binding var isLoading: Bool
    let videoURL: URL?
    
    init(isLoading: Binding<Bool>, videoURL: URL?) {
        _viewModel = StateObject(wrappedValue: TrimEditorViewModel())
        _isLoading = isLoading
        self.videoURL = videoURL
    }
    var body: some View {
        VStack {
            header
            video
            slider
            addWaterMark
            Spacer()
        }
        .onAppear {
            isLoading = false
            if let videoURL = videoURL {
                viewModel.loadVideoInfo(from: videoURL)
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(Font.custom(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
                Spacer()
                
                Text("Watermark")
                    .foregroundStyle(Color.black)
                    .font(Font.custom(size: 16, weight: .bold))
                Spacer()
                Button("Done") {
                    if let videoURL = videoURL {
                        viewModel.saveWaterMarkedFileToDB(fileName: videoURL.absoluteString, type: "Video")
                        dismiss()
                    }
                }
                .font(Font.custom(size: 16, weight: .bold))
                .foregroundColor(.black)
            }

            Button("Reset settings") {
            }
            .foregroundStyle(Color.black)
            .font(Font.custom(size: 16, weight: .bold))
        }
        .padding()
    }
    
    @ViewBuilder
    private var video: some View {
        if let player = viewModel.getPlayer() {
            let maxHeight: CGFloat = 320
            
            ZStack {
                VideoPlayer(player: player)
                    .frame(height: maxHeight)
                    .cornerRadius(16)

                if let watermarkImage = viewModel.watermarkImage {
                    Image(uiImage: watermarkImage)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .offset(x: viewModel.watermarkOffset.width + viewModel.dragOffset.width,
                                y: viewModel.watermarkOffset.height + viewModel.dragOffset.height)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    viewModel.dragOffset = gesture.translation
                                }
                                .onEnded { gesture in
                                    viewModel.watermarkOffset.width += gesture.translation.width
                                    viewModel.watermarkOffset.height += gesture.translation.height
                                    viewModel.dragOffset = .zero
                                }
                        )
                        .padding()
                }
            }
            .frame(height: maxHeight)
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

    private var addWaterMark: some View {
        VStack {
            PhotosPicker(
                selection: $viewModel.selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack {
                    Text("Add a watermark")
                        .font(Font.custom(size: 16, weight: .regular))
                        .foregroundColor(.gray50)
                    Spacer()
                    Image(.iconoirImport)
                }
                .padding(.vertical, 10)
            }

            Divider()
                .overlay(Color.gray50)
                .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

#Preview {
    WatermarkEditorView(isLoading: .constant(false), videoURL: URL(string: "video.mov"))
}

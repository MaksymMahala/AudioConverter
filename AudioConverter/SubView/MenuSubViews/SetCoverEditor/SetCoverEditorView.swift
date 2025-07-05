//
//  SetCoverEditorView.swift
//  AudioConverter
//
//  Created by Max on 05.07.2025.
//

import SwiftUI
import AVKit

struct SetCoverEditorView: View {
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
        .sheet(isPresented: $viewModel.isPresentedSetCoverSheet) {
            SetCoverSheetView(selectedImage: $viewModel.setCoverImage)
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
                    Task {
                        if let videoURL = videoURL {
                            await viewModel.saveCoveredFileToDB(fileName: videoURL.absoluteString, type: "Video")
                            if let controller = ShareHelper.getRootController() {
                                ShareManager.shared.shareFiles([videoURL], from: controller)
                            }
                            dismiss()
                        }
                    }
                }
                .font(Font.custom(size: 16, weight: .bold))
                .foregroundColor(.black)
            }

            Button("Reset settings") {
                viewModel.setCoverImage = nil
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

                if let watermarkImage = viewModel.setCoverImage {
                    Image(uiImage: watermarkImage)
                        .resizable()
                        .frame(height: 320)
                        .frame(maxWidth: .infinity)
                        .offset(x: viewModel.watermarkOffset.width + viewModel.dragOffset.width,
                                y: viewModel.watermarkOffset.height + viewModel.dragOffset.height)
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
            Button {
                viewModel.isPresentedSetCoverSheet = true
            } label: {
                HStack {
                    Text("Add cover")
                        .font(Font.custom(size: 16, weight: .regular))
                        .foregroundColor(.gray50)
                    Spacer()
                    Image(.iconoirImport)
                }
            }
            .padding(.vertical, 10)

            Divider()
                .overlay(Color.gray50)
        }
        .padding(.horizontal)
    }
}

#Preview {
    SetCoverEditorView(isLoading: .constant(false), videoURL: URL(string: "video.mov"))
}

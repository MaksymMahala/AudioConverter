//
//  VideoToolsView.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct VideoToolsView: View {
    @Binding var isLoadingVideo: Bool
    @StateObject private var viewModel = VideoToolsViewModel()
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(.iconoirVideo)
                Text("Video")
            }
            .foregroundStyle(Color.darkBlueD90)
            .font(Font.custom(size: 18, weight: .bold))
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.tools) { tool in
                    Button {
                        switch tool.title {
                        case "Convert video":
                            withAnimation {
                                viewModel.videoAction = .convert
                                viewModel.openAudioView = true
                            }
                        case "Video to audio":
                            withAnimation {
                                viewModel.videoAction = .videoToAudio
                                viewModel.openAudioView = true
                            }
                        case "Trim video":
                            withAnimation {
                                viewModel.videoAction = .trim
                                viewModel.openAudioView = true
                            }
                        case "Cut video":
                            withAnimation {
                                viewModel.videoAction = .cut
                                viewModel.openAudioView = true
                            }
                        case "Compress video":
                            withAnimation {
                                viewModel.videoAction = .compress
                                viewModel.openAudioView = true
                            }
                        case "Delete a video":
                            withAnimation {
                                viewModel.videoAction = .delete
                                viewModel.openAudioView = true
                            }
                        default:
                            withAnimation {
                                viewModel.videoAction = .convert
                                viewModel.openAudioView = true
                            }
                        }
                    } label: {
                        ToolCard(tool: tool)
                    }
                }
            }
            .padding(.top, 10)
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.toolsHorizontal) { tool in
                    Button {
                        withAnimation {
                            
                        }
                    } label: {
                        ToolCardHorizontal(tool: tool)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 6)
        }
        .sheet(isPresented: $viewModel.openAudioView) {
            VideoConversionSheet(isLoadingVideo: $isLoadingVideo, viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $viewModel.isEditorPresented) {
            VideoToAudioEditorView(videoURL: viewModel.videoURL, isLoading: $isLoadingVideo, isEditorPresented: $viewModel.isEditorPresented)
        }
        .fullScreenCover(isPresented: $viewModel.isCutEditorPresented) {
            CutVideoEditorView(isLoading: $isLoadingVideo, videoURL: viewModel.videoURL)
        }
    }
}

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
                            if PurchaseManager.instance.userPurchaseIsActive {
                                withAnimation {
                                    viewModel.videoAction = .trim
                                    viewModel.openAudioView = true
                                }
                            }
                        case "Cut video":
                            if PurchaseManager.instance.userPurchaseIsActive {
                                withAnimation {
                                    viewModel.videoAction = .cut
                                    viewModel.openAudioView = true
                                }
                            }
                        case "Compress video":
                            PurchaseManager.instance.canPerformFreeActionTodayOrHasSubscription { isAccess in
                                if isAccess {
                                    withAnimation {
                                        viewModel.videoAction = .compress
                                        viewModel.openAudioView = true
                                    }
                                }
                            }
                        case "Delete a video":
                            PurchaseManager.instance.checkTrialOrPurchase { allowed in
                                if allowed {
                                    withAnimation {
                                        viewModel.videoAction = .delete
                                        viewModel.openAudioView = true
                                    }
                                }
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
                        switch tool.title {
                        case "Add Watermark":
                            PurchaseManager.instance.checkTrialOrPurchase { allowed in
                                if allowed {
                                    withAnimation {
                                        viewModel.videoAction = .waterMark
                                        viewModel.openAudioView = true
                                    }
                                }
                            }
                        case "Set cover":
                            if PurchaseManager.instance.userPurchaseIsActive {
                                withAnimation {
                                    viewModel.videoAction = .setCover
                                    viewModel.openAudioView = true
                                }
                            }
                        default:
                            if PurchaseManager.instance.userPurchaseIsActive {
                                withAnimation {
                                    viewModel.videoAction = .waterMark
                                    viewModel.openAudioView = true
                                }
                            }
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
        .fullScreenCover(isPresented: $viewModel.isCompressEditorPresented) {
            CompressEditorView(isLoading: $isLoadingVideo, videoURL: viewModel.videoURL)
        }
        .fullScreenCover(isPresented: $viewModel.isTrimEditorPresented) {
            TrimEditorView(isLoading: $isLoadingVideo, videoURL: viewModel.videoURL)
        }
        .fullScreenCover(isPresented: $viewModel.isAddWatermarkEditorPresented) {
            WatermarkEditorView(isLoading: $isLoadingVideo, videoURL: viewModel.videoURL)
        }
        .fullScreenCover(isPresented: $viewModel.isDeleteEditorPresented) {
            DeleteAVideoEditorView(isLoading: $isLoadingVideo, videoURL: viewModel.videoURL)
        }
        .fullScreenCover(isPresented: $viewModel.isSetCoverEditorPresented) {
            SetCoverEditorView(isLoading: $isLoadingVideo, videoURL: viewModel.videoURL)
        }
    }
}

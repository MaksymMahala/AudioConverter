//
//  AudioToolsView.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct AudioToolsView: View {
    @StateObject private var viewModel = AudioConversionViewModel()
    @Binding var isLoadingAudio: Bool

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label {
                Text("Audio")
                    .foregroundStyle(Color.darkBlueD90)
                    .font(Font.custom(size: 18, weight: .bold))
            } icon: {
                Image(.iconoirPlay)
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.tools) { tool in
                    Button {
                        switch tool.title {
                        case "Audio conversion":
                            withAnimation {
                                viewModel.openAudioView = true
                                viewModel.audioAction = .convert
                            }
                        case "Create a melody":
                            if PurchaseManager.instance.userPurchaseIsActive {
                                withAnimation {
                                    viewModel.audioAction = .createMelody
                                    viewModel.openAudioView = true
                                }
                            }
                        case "Trim audio":
                            PurchaseManager.instance.canPerformFreeActionTodayOrHasSubscription { isAccess in
                                if isAccess {
                                    withAnimation {
                                        viewModel.audioAction = .trim
                                        viewModel.openAudioView = true
                                    }
                                }
                            }
                        case "Edit Audio":
                            withAnimation {
                                viewModel.openAudioView = true
                                viewModel.audioAction = .edit
                            }
                        default:
                            withAnimation {
                                viewModel.audioAction = .convert
                                viewModel.openAudioView = true
                            }
                        }
                    } label: {
                        ToolCard(tool: tool)
                    }
                }
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $viewModel.openAudioView) {
            AudioConversionSheet(viewModel: viewModel, isLoadingAudio: $isLoadingAudio)
        }
        .fullScreenCover(isPresented: $viewModel.isEditorPresented) {
            AudioToVideoEditorView(audioURL: viewModel.audioURL, audioAction: viewModel.audioAction, isLoading: $isLoadingAudio, isEditorPresented: $viewModel.isEditorPresented)
        }
    }
}

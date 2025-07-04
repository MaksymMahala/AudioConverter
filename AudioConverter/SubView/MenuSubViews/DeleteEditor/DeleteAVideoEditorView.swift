//
//  DeleteAVideoEditorView.swift
//  AudioConverter
//
//  Created by Max on 04.07.2025.
//

import SwiftUI
import AVKit

struct DeleteAVideoEditorView: View {
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
            settingsSection
            Spacer()
        }
        .sheet(isPresented: $viewModel.isNumberOfWaterMarkView) {
            NumberOfWatermarksView(selectedNumberWaterMarks: $viewModel.selectedNumberWaterMarks, hasProAccess: false)
                .presentationDetents([.fraction(0.3)])
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
                
                Text("Delete a video")
                    .foregroundStyle(Color.black)
                    .font(Font.custom(size: 16, weight: .bold))
                Spacer()
                Button("Done") {
                    if let videoURL = viewModel.videoURL {
                        viewModel.saveFileToDB(fileName: videoURL.absoluteString, type: "Video")
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
            ZStack(alignment: .topLeading) {
                VideoPlayer(player: player)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(16)
                    .padding(.horizontal)

                Button {
                    viewModel.blurAction()
                } label: {
                    Image(.iconoirErasePurple)
                        .padding()
                        .frame(width: 100, height: 100)
                        .background(Color.darkPurple.opacity(0.6))
                        .cornerRadius(20)
                        .padding(.leading, 40)
                        .padding(.top)
                }

                if viewModel.isPresentedLoading {
                    CustomLoadingView()
                }
            }
        } else {
            Color.clear.frame(height: 320).padding(.horizontal)
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
    
    private var settingsSection: some View {
        VStack(spacing: 12) {
            settingRow(title: "Number of watermarks", value: "\(viewModel.selectedNumberWaterMarks)") {
                viewModel.pausePlayer()
                viewModel.isNumberOfWaterMarkView = true
            }
            
            Divider()
                .overlay(Color.gray50)
        }
        .padding(.horizontal)
        .padding(.top, 20)
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
    DeleteAVideoEditorView(isLoading: .constant(false), videoURL: URL(string: "video.mp4"))
}

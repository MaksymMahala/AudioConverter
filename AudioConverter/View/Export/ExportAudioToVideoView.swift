//
//  ExportAudioToVideoView.swift
//  AudioConverter
//
//  Created by Max on 02.07.2025.
//

import SwiftUI
import AVKit

struct ExportAudioToVideoView: View {
    let audioURL: URL?
    @Binding var selectedFormat: String
    @Binding var isEditorPresented: Bool

    @Environment(\.dismiss) private var dismiss
    @State private var exportURL: URL?
    @ObservedObject var playerViewModel: PlayerViewModel

    var body: some View {
        ZStack {
            if exportURL == nil {
                CustomLoadingView()
            } else {
                VStack(spacing: 20) {
                    if let videoURL = exportURL {
                        VideoPlayer(player: AVPlayer(url: videoURL))
                            .frame(height: 220)
                            .cornerRadius(16)
                            .padding(.horizontal)
                    } else {
                        Color.clear.frame(height: 220).padding(.horizontal)
                    }
                    
                    Text(exportURL?.lastPathComponent ?? "Video")
                        .font(Font.custom(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .padding(.horizontal)

                    VStack {
                        if let duration = playerViewModel.duration {
                            Slider(
                                value: $playerViewModel.currentTime,
                                in: 0...(duration > 0 ? duration : 1),
                                onEditingChanged: { editing in
                                    if !editing {
                                        playerViewModel.seek(to: playerViewModel.currentTime)
                                    }
                                }
                            )
                            .accentColor(.darkPurple)
                            .padding(.horizontal)
                        }

                        HStack {
                            Text(playerViewModel.formatTime(playerViewModel.currentTime))
                            Spacer()
                            if let duration = playerViewModel.duration {
                                Text(playerViewModel.formatTime(duration))
                            }
                        }
                        .font(Font.custom(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    }

                    HStack(spacing: 50) {
                        Button {
                            playerViewModel.seek(by: -5)
                        } label: {
                            Image(.iconoirSkipPrevSolid)
                        }

                        Button {
                            playerViewModel.togglePlayPause()
                        } label: {
                            Image(systemName: playerViewModel.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.black)
                        }

                        Button {
                            playerViewModel.seek(by: 5)
                        } label: {
                            Image(.iconoirSkipNextSolid)
                        }
                    }

                    Spacer()
                    
                    Button {
                        if let url = exportURL {
                            playerViewModel.saveConvertedFileToDB(url: url, fileName: url.lastPathComponent, type: "Video")
                            isEditorPresented = false
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Text("Share")
                                .foregroundStyle(Color.white)
                                .font(Font.custom(size: 16, weight: .medium))
                            Image(.iconoirShareIos)
                        }
                        .padding(13)
                        .frame(maxWidth: .infinity)
                        .background(Color.darkPurple)
                        .cornerRadius(30)
                        .padding(.horizontal)
                        .padding(.top, 30)
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            guard let audioURL else { return }
            
            playerViewModel.load(url: audioURL)
            playerViewModel.applyEffect(nil)
            
            convertToVideo(audioURL: audioURL, format: selectedFormat) { url in
                if let url {
                    exportURL = url
                } else {
                    print("Video export failed")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("My files")
                    }
                    .foregroundStyle(Color.blue)
                }
            }
        }
    }
    
    private func convertToVideo(audioURL: URL, format: String, completion: @escaping (URL?) -> Void) {
        VideoGenerator.createVideoFromAudio(audioURL: audioURL, outputFormat: format) { url in
            DispatchQueue.main.async {
                if let url = url {
                    print("Video generated at: \(url)")
                    completion(url)
                } else {
                    print("Failed to generate video")
                    completion(nil)
                }
            }
        }
    }
}

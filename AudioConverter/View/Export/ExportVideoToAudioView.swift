//
//  ExportView.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import SwiftUI

struct ExportVideoToAudioView: View {
    @State private var exportURL: URL?
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var playerViewModel: PlayerViewModel
    @Binding var isEditorPresented: Bool

    var body: some View {
        ZStack {
            if exportURL == nil {
                CustomLoadingView()
            } else {
                VStack(spacing: 20) {
                    if exportURL != nil {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 220)
                            .overlay(
                                Image(systemName: "waveform")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(Color.gray50)
                            )
                            .cornerRadius(16)
                            .padding(.horizontal)
                    } else {
                        Color.clear.frame(height: 220).padding(.horizontal)
                    }
                    
                    Text(exportURL?.lastPathComponent ?? "Audio")
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
                    
                    Button {
                        if let convertedURL = exportURL {
                              playerViewModel.saveConvertedFileToDB(url: convertedURL, fileName: convertedURL.lastPathComponent, type: "Audio")
                              isEditorPresented = false
                              dismiss()
                          } else {
                              print("No converted file to save")
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
            guard let audioURL = playerViewModel.audioFile?.url else {
                print("No audio URL to convert")
                return
            }

            playerViewModel.convertToAudio(originalAudioURL: audioURL) { url in
                if let url = url {
                    exportURL = url
                    print("Conversion succeeded, file: \(url)")
                } else {
                    print("Conversion failed")
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
}

#Preview {
    ExportVideoToAudioView(playerViewModel: PlayerViewModel(), isEditorPresented: .constant(false))
}

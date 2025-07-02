//
//  AudioEditorView.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import SwiftUI

struct VideoEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerViewModel = PlayerViewModel()
    let videoURL: URL?
    @Binding var isLoading: Bool
    @Binding var isEditorPresented: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    header
                    waveformSection
                    controls
                    Divider()
                        .padding(.top, 30)
                    conditionalContent
                    Spacer()
                    tabs
                }
            }
            .onChange(of: videoURL) { newValue, _ in
                loadMedia()
            }
            .onAppear {
                isLoading = false
                loadMedia()
            }
        }
    }
    
    private func loadMedia() {
        guard let url = videoURL else { return }
        isLoading = true
        playerViewModel.waveform = []
        
        VideoAudioConverter.extractAudio(from: url) { result in
            switch result {
            case .success(let audioURL):
                DispatchQueue.main.async {
                    self.playerViewModel.load(url: audioURL)
                    self.playerViewModel.applyEffect(nil)
                    Task {
                        let samples = await AudioWaveformProvider.extractAmplitudes(from: audioURL)
                        await MainActor.run {
                            withAnimation(.easeInOut) {
                                self.playerViewModel.waveform = samples
                                self.isLoading = false
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Failed to extract audio: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: UI Components
    private var header: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(.iconoirXmark)
                }
                Spacer()
                if playerViewModel.selectedTab == "File format" {
                    NavigationLink {
                        if let fileName = videoURL?.lastPathComponent {
                            ExportView(fileName: fileName, playerViewModel: playerViewModel, isEditorPresented: $isEditorPresented)
                        }
                    } label: {
                        Text("Export")
                            .foregroundColor(.black)
                            .font(Font.custom(size: 16, weight: .bold))
                    }
                } else {
                    Button("Next") {
                        withAnimation {
                            playerViewModel.selectedTab = "File format"
                        }
                    }
                    .foregroundColor(.black)
                    .font(Font.custom(size: 16, weight: .bold))
                }
            }
            Text(videoURL?.lastPathComponent ?? "Audio")
                .foregroundStyle(Color.black)
                .font(Font.custom(size: 16, weight: .bold))
                .padding(.top, 10)
        }
        .padding(.horizontal)
    }
    
    private var waveformSection: some View {
        let duration = playerViewModel.duration ?? 1
        let currentTimeBinding = Binding<Double>(
            get: { playerViewModel.currentTime },
            set: { newValue in
                playerViewModel.currentTime = newValue
            }
        )
        let progress = CGFloat(playerViewModel.currentTime / duration)

        return VStack(spacing: 12) {
            WaveformView(amplitudes: playerViewModel.waveform, progress: progress)
                .frame(height: 120)
                .padding(.horizontal)

            VStack {
                Slider(
                    value: currentTimeBinding,
                    in: 0...duration,
                    onEditingChanged: { editing in
                        if !editing {
                            playerViewModel.seek(to: playerViewModel.currentTime)
                        }
                    }
                )
                .accentColor(.darkBlueD90)
                .padding(.horizontal, 10)

                HStack {
                    Text(playerViewModel.formatTime(playerViewModel.currentTime))
                    Spacer()
                    Text(playerViewModel.formatTime(duration))
                }
                .font(Font.custom(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .padding(.horizontal)
            }
        }
    }
    
    private var controls: some View {
        HStack {
            Spacer()
            
            controlButton("arrow.uturn.backward") { playerViewModel.seek(to: 0) }
            
            Spacer()
            
            controlButton("backward.fill") { playerViewModel.seek(by: -5) }
            Button(action: playerViewModel.togglePlayPause) {
                Image(systemName: playerViewModel.isPlaying ? "pause" : "play")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.gray20.opacity(0.5))
                    .cornerRadius(30)
            }
            controlButton("forward.fill") { playerViewModel.seek(by: 5) }
            
            Spacer()
            Spacer()
            Spacer()
        }
        .padding(.top, 12)
    }
    
    private var effectsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(playerViewModel.effects, id: \.self) { effect in
                    Button {
                        playerViewModel.applyEffect(effect)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .foregroundColor(.darkBlueD90)
                                .padding()
                                .background(Color.gray20.opacity(0.5))
                                .clipShape(Circle())
                                .scaleEffect(playerViewModel.currentEffect == effect ? 1.0 : 0.8)
                                .animation(.easeInOut(duration: 0.2), value: playerViewModel.currentEffect)

                            Text(effect)
                                .font(Font.custom(size: 14, weight: .regular))
                                .foregroundColor(.darkBlueD90)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var tabs: some View {
        HStack {
            tabButton(title: "Editing")
            tabButton(title: "File format")
        }
        .frame(height: 30)
        .background(Color(.gray20).opacity(0.5))
        .clipShape(Capsule())
        .padding()
    }
    
    private var conditionalContent: some View {
        Group {
            if playerViewModel.selectedTab == "Editing" {
                effectsScroll
            } else if playerViewModel.selectedTab == "File format" {
                formatScroll
            }
        }
    }
    
    private var formatScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(playerViewModel.availableFormats, id: \.self) { format in
                    Button {
                        playerViewModel.selectedFormat = format
                    } label: {
                        Text(format)
                            .font(Font.custom(size: 16, weight: .medium))
                            .foregroundColor(.darkBlueD90)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .frame(height: 78)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(playerViewModel.selectedFormat == format ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    func controlButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .resizable()
                .frame(width: 15, height: 15)
                .foregroundColor(.black)
                .padding()
                .background(Color.gray20.opacity(0.5))
                .cornerRadius(30)
        }
    }
    
    func tabButton(title: String) -> some View {
        Button(action: { playerViewModel.selectedTab = title }) {
            Text(title)
                .font(Font.custom(size: 16, weight: .regular))
                .foregroundColor(playerViewModel.selectedTab == title ? .darkBlueD90 : .gray50)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .background(playerViewModel.selectedTab == title ? Color.secondary0110 : Color.clear)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    VideoEditorView(videoURL: URL(string: "https://video.com"), isLoading: .constant(false), isEditorPresented: .constant(true))
}

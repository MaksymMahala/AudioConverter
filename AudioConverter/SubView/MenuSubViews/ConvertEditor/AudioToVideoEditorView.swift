//
//  AudioToVideoEditorView.swift
//  AudioConverter
//
//  Created by Max on 02.07.2025.
//

import SwiftUI

struct AudioToVideoEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerViewModel = PlayerViewModel()
    
    let audioURL: URL?
    let audioAction: AudioAction

    @Binding var isLoading: Bool
    @Binding var isEditorPresented: Bool
    
    @State private var trimmedAudioURL: URL?
    @State private var isTrimNavigationActive = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                header
                waveformSection
                controls
                
                if audioAction == .convert || audioAction == .edit {
                    Divider()
                        .padding(.top, 30)
                    conditionalContent
                } else if audioAction == .trim {
                    trimControls
                    Divider()
                        .padding(.top)
                }
                
                Spacer()
                
                if audioAction == .convert || audioAction == .edit {
                    tabs
                }
            }
            .fullScreenCover(isPresented: $isTrimNavigationActive) {
                 ExportAudioToVideoView(
                    audioAction: audioAction,
                    audioURL: audioAction == .trim ? trimmedAudioURL : audioURL,
                    selectedFormat: $playerViewModel.selectedFormat,
                    isEditorPresented: $isEditorPresented,
                    playerViewModel: playerViewModel
                 )
             }
            .onChange(of: audioURL) { newValue, _ in
                loadAudio()
            }
            .onAppear {
                playerViewModel.fileType = .audio
                isLoading = false
                loadAudio()
            }
        }
    }
    
    private func loadAudio() {
        guard let url = audioURL else { return }
        isLoading = true
        playerViewModel.waveform = []
        
        DispatchQueue.main.async {
            playerViewModel.load(url: url)
            playerViewModel.applyEffect(nil)
            
            Task {
                let samples = await AudioWaveformProvider.extractAmplitudes(from: url)
                await MainActor.run {
                    withAnimation(.easeInOut) {
                        playerViewModel.waveform = samples
                        isLoading = false
                    }
                }
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(.iconoirXmark)
                }
                Spacer()
                if audioAction == .trim {
                    Button("Export") {
                        guard let originalURL = audioURL else { return }
                        playerViewModel.exportTrimmedAudio(from: originalURL) { url in
                            guard let url = url else { return }
                            trimmedAudioURL = url
                            isTrimNavigationActive = true
                        }
                    }
                    .foregroundColor(.black)
                    .font(Font.custom(size: 16, weight: .bold))
                } else if audioAction == .createMelody {
                    NavigationLink {
                        ExportAudioToVideoView(
                            audioAction: audioAction,
                            audioURL: audioURL,
                            selectedFormat: $playerViewModel.selectedFormat,
                            isEditorPresented: $isEditorPresented,
                            playerViewModel: playerViewModel
                        )
                    } label: {
                        Text("Export")
                            .foregroundColor(.black)
                            .font(Font.custom(size: 16, weight: .bold))
                    }
                } else {
                    if playerViewModel.selectedTab == "File format" {
                        NavigationLink {
                            ExportAudioToVideoView(
                                audioAction: audioAction,
                                audioURL: audioURL,
                                selectedFormat: $playerViewModel.selectedFormat,
                                isEditorPresented: $isEditorPresented,
                                playerViewModel: playerViewModel
                            )
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
            }
            Text(audioURL?.lastPathComponent ?? "Audio")
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

        let trimStartProgress = CGFloat(playerViewModel.timeRangeStart / duration)
        let trimEndProgress = CGFloat(playerViewModel.timeRangeEnd / duration)

        let progress = CGFloat(playerViewModel.currentTime / duration)

        return VStack(spacing: 12) {
            ZStack(alignment: .leading) {
                WaveformView(amplitudes: playerViewModel.waveform, progress: progress)
                    .frame(height: 120)
                    .padding(.horizontal)

                if audioAction == .trim {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.primary130.opacity(0.5))
                            .frame(
                                width: geo.size.width * (trimEndProgress - trimStartProgress),
                                height: geo.size.height
                            )
                            .offset(x: geo.size.width * trimStartProgress)
                            .allowsHitTesting(false)
                    }
                    .frame(height: 120)
                }
            }


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
    
    private var trimControls: some View {
        VStack(spacing: 16) {
            RangeSlider(
                minValue: $playerViewModel.currentTime,
                maxValue: $playerViewModel.timeRangeEnd,
                range: 0...(playerViewModel.duration ?? 1)
            )
            .frame(height: 40)
            .padding(.horizontal)

            HStack {
                Text("Trim Range:")
                Spacer()
                Text("\(formatTime(playerViewModel.timeRangeStart)) - \(formatTime(playerViewModel.timeRangeEnd))")
                Text(String(format: "%.1fs", playerViewModel.timeRangeEnd - playerViewModel.timeRangeStart))
            }
            .font(.system(size: 13))
            .foregroundColor(.gray)
            .padding(.horizontal)
            
            HStack {
                timeAdjusterControl(time: $playerViewModel.timeRangeStart)
                Spacer()
                timeAdjusterControl(time: $playerViewModel.timeRangeEnd)
            }
            .padding(.horizontal)
        }
    }

    private func timeAdjusterControl(time: Binding<Double>) -> some View {
        HStack(spacing: 10) {
            Button(action: {
                time.wrappedValue = max(time.wrappedValue - 0.02, 0)
            }) {
                Text("-")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
            }

            Text(formatTime3Digits(time.wrappedValue))
                .font(Font.custom(size: 12, weight: .regular))
                .foregroundColor(Color.gray50)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)

            Button(action: {
                time.wrappedValue = min(time.wrappedValue + 0.02, playerViewModel.duration ?? 1)
            }) {
                Text("+")
                    .font(.custom(size: 23, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    private func formatTime3Digits(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let ms = Int((seconds - Double(minutes * 60 + secs)) * 1000)
        return String(format: "%02d:%02d:%03d", minutes, secs, ms)
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

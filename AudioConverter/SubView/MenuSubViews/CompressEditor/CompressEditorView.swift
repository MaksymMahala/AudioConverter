//
//  CompressEditorView.swift
//  AudioConverter
//
//  Created by Max on 04.07.2025.
//

import SwiftUI
import AVKit

struct CompressEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CompressVideoEditorViewModel
    @Binding var isLoading: Bool
    let videoURL: URL?
    
    init(isLoading: Binding<Bool>, videoURL: URL?) {
        _viewModel = StateObject(wrappedValue: CompressVideoEditorViewModel())
        _isLoading = isLoading
        self.videoURL = videoURL
    }
    var body: some View {
        VStack {
            header
            video
            slider
            settingsSection
            timeRangeSlider
            Spacer()
        }
        .onAppear {
            isLoading = false
            if let videoURL = videoURL {
                viewModel.loadVideoInfo(from: videoURL)
            }
        }
        .sheet(isPresented: $viewModel.openResolution) {
            ResolutionPickerView(
                selectedResolution: $viewModel.selectedResolution,
                originalResolution: viewModel.selectedResolution ?? ResolutionOption(size: CGSize(width: 480, height: 720))
            )
        }
        .sheet(isPresented: $viewModel.openFrameRate) {
            FrameRateView(selectedFrameRate: $viewModel.selectedFrameRate, isVideo: true, hasProAccess: false)
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(Font.custom(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            Spacer()
            Text("Compress video")
                .foregroundStyle(Color.black)
                .font(Font.custom(size: 16, weight: .bold))
            Spacer()
            Button("Done") {
                if let videoURL = videoURL {
                    viewModel.saveFileToDB(fileName: videoURL.absoluteString, type: "Video")
                    dismiss()
                }
            }
            .font(Font.custom(size: 16, weight: .bold))
            .foregroundColor(.black)
        }
        .padding()
    }
    
    @ViewBuilder
    private var video: some View {
        if let player = viewModel.getPlayer(), let resolution = viewModel.selectedResolution {
            let maxHeight: CGFloat = 320
            let scaleFactor = maxHeight / resolution.size.height
            
            VideoPlayer(player: player)
                .frame(width: resolution.size.width * scaleFactor, height: maxHeight)
                .cornerRadius(16)
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
    
    private var settingsSection: some View {
        VStack(spacing: 12) {
            settingRow(title: "Resolution", value: viewModel.selectedResolution?.value ?? "") {
                viewModel.pausePlayer()
                viewModel.openResolution = true
            }

            Divider()
                .overlay(Color.gray50)

            settingRow(title: "Frame rate", value: "\(viewModel.selectedFrameRate) fps") {
                viewModel.pausePlayer()
                viewModel.openFrameRate = true
            }

            Divider()
                .overlay(Color.gray50)

            HStack {
                Text("Time range")
                    .font(Font.custom(size: 16, weight: .regular))
                    .foregroundColor(.gray50)
                Spacer()
                Text("\(viewModel.timeString(from: viewModel.timeRangeStart)) - \(viewModel.timeString(from: viewModel.timeRangeEnd)) \(String(format: "%.1fs", viewModel.timeRangeEnd - viewModel.timeRangeStart))")
                    .foregroundColor(.gray50)
                    .font(Font.custom(size: 16, weight: .regular))
            }
        }
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    private var timeRangeSlider: some View {
        VStack(spacing: 10) {
            RangeSlider(minValue: $viewModel.timeRangeStart, maxValue: $viewModel.timeRangeEnd, range: 0...viewModel.duration, onEditingChanged: { editing in
                viewModel.isEditingTimeRange = editing
            })
            .frame(height: 40)
            .padding(.horizontal)

            HStack {
                timeAdjusterControl(time: $viewModel.timeRangeStart)
                Spacer()
                timeAdjusterControl(time: $viewModel.timeRangeEnd)
            }
            .padding(.horizontal, 20)

            Divider()
                .overlay(Color.gray50)
                .padding()
        }
        .padding(.top, 12)
    }
    
    private func timeAdjusterControl(time: Binding<Double>) -> some View {
        HStack(spacing: 10) {
            Button(action: {
                if time.wrappedValue == viewModel.startTime {
                    viewModel.decreaseStartTime()
                } else {
                    viewModel.decreaseEndTime()
                }
            }) {
                Text("-")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
            }

            Text(viewModel.timeString(from: time.wrappedValue))
                .font(Font.custom(size: 12, weight: .regular))
                .foregroundColor(Color.gray50)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)

            Button(action: {
                if time.wrappedValue == viewModel.startTime {
                    viewModel.increaseStartTime()
                } else {
                    viewModel.increaseEndTime()
                }
            }) {
                Text("+")
                    .font(.custom(size: 23, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
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
    CompressEditorView(isLoading: .constant(false), videoURL: URL(string: "video.mp4"))
}

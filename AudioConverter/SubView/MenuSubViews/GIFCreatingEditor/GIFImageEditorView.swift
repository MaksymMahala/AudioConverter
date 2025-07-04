//
//  GIFImageEditorView.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import SwiftUI

struct GIFImageEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: GIFImageEditorViewModel
    @Binding var isLoading: Bool
    
    init(image: UIImage?, isLoading: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: GIFImageEditorViewModel(image: image))
        _isLoading = isLoading
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            videoPreview
            timelineSlider
            settingsSection
            timeRangeSlider
            Spacer()
        }
        .onAppear {
            isLoading = false
        }
        .sheet(isPresented: $viewModel.openResolution) {
            ResolutionPickerView(
                selectedResolution: $viewModel.selectedResolution,
                originalResolution: viewModel.selectedResolution ?? ResolutionOption(size: CGSize(width: 480, height: 720))
            )
        }
        .sheet(isPresented: $viewModel.openFrameRate) {
            FrameRateView(selectedFrameRate: $viewModel.selectedFrameRate)
        }
        .sheet(isPresented: $viewModel.openNumberOfCycles) {
            NumberOfCyclesView(selectedNumberOfCycles: $viewModel.selectedNumberOfCycles)
        }
        .navigationBarHidden(true)
        .background(Color.white)
    }

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(Font.custom(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            Spacer()
            Text("Creating GIF files")
                .foregroundStyle(Color.black)
                .font(Font.custom(size: 16, weight: .bold))
            Spacer()
            Button("Done") {
                viewModel.saveEditedImageToDB(selectedImage: viewModel.image)
                dismiss()
            }
            .font(Font.custom(size: 16, weight: .bold))
            .foregroundColor(.black)
        }
        .padding()
    }

    private var videoPreview: some View {
        ZStack {
            if let gifURL = viewModel.generatedGIFURL {
                WebGIFView(gifURL: gifURL)
                    .frame(height: 220)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 220)

                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
            }
        }
    }

    private var timelineSlider: some View {
        VStack(spacing: 4) {
            Slider(value: $viewModel.currentTime, in: 0...viewModel.duration)
                .accentColor(Color.darkPurple)

            HStack {
                Text(timeString(from: viewModel.currentTime))
                Spacer()
                Text(timeString(from: viewModel.duration))
            }
            .foregroundStyle(Color.grayE96)
            .font(Font.custom(size: 15, weight: .regular))
            .padding(.horizontal)
        }
        .padding(.top, 8)
    }

    private var settingsSection: some View {
        VStack(spacing: 12) {
            settingRow(title: "Resolution", value: viewModel.selectedResolution?.value ?? "") {
                viewModel.openResolution = true
            }

            Divider()
                .overlay(Color.gray50)

            settingRow(title: "Frame rate", value: "\(viewModel.selectedFrameRate) fps") {
                viewModel.openFrameRate = true
            }

            Divider()
                .overlay(Color.gray50)

            settingRow(title: "Number of cycles", value: viewModel.numberOfCyclesText) {
                viewModel.openNumberOfCycles = true
            }

            Divider()
                .overlay(Color.gray50)

            HStack {
                Text("Time range")
                    .font(Font.custom(size: 16, weight: .regular))
                    .foregroundColor(.gray50)
                Spacer()
                Text("\(timeString(from: viewModel.timeRangeStart)) - \(timeString(from: viewModel.timeRangeEnd)) \(String(format: "%.1fs", viewModel.timeRangeEnd - viewModel.timeRangeStart))")
                    .foregroundColor(.gray50)
                    .font(Font.custom(size: 16, weight: .regular))
            }
        }
        .padding(.horizontal)
        .padding(.top, 40)
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
                time.wrappedValue = max(time.wrappedValue - 0.02, 0)
            }) {
                Text("-")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
            }

            Text(timeString3Digits(from: time.wrappedValue))
                .font(Font.custom(size: 12, weight: .regular))
                .foregroundColor(Color.gray50)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)

            Button(action: {
                time.wrappedValue = min(time.wrappedValue + 0.02, viewModel.duration)
            }) {
                Text("+")
                    .font(.custom(size: 23, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
    }

    private func timeString(from seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let min = totalSeconds / 60
        let sec = totalSeconds % 60
        return String(format: "%02d:%02d", min, sec)
    }

    private func timeString3Digits(from seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let min = totalSeconds / 60
        let sec = totalSeconds % 60
        let ms = Int((seconds - Double(totalSeconds)) * 1000)
        return String(format: "%02d:%02d:%03d", min, sec, ms)
    }
}

#Preview {
    GIFImageEditorView(image: UIImage(named: "iconoir_plus-circle-solid"), isLoading: .constant(false))
}

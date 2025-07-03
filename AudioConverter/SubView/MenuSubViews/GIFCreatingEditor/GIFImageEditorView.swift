//
//  GIFImageEditorView.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import SwiftUI

struct GIFImageEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    //resolution
    @State private var openNumberOfCycles = false
    @State private var openFrameRate = false
    @State private var openResolution = false
    @State private var selectedResolution: ResolutionOption?
    @State private var frameRate = 15
    @State private var numberOfCycles = "Endless looping"
    @State private var timeRangeStart = 4.0
    @State private var timeRangeEnd = 9.0
    @State private var currentTime = 30.0
    let duration = 216.0

    //numberOfCycles
    @State private var selectedNumberOfCycles: Int?
    
    //frameRate
    @State private var selectedFrameRate: Int?

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
            selectedResolution = ResolutionOption(value: "480*720", isPro: false)
        }
        .sheet(isPresented: $openResolution) {
            if let originalResolution = selectedResolution {
                ResolutionPickerView(selectedResolution: $selectedResolution, originalResolution: originalResolution)
            }
        }
        .sheet(isPresented: $openFrameRate) {
            FrameRateView(selectedFrameRate: $selectedFrameRate)
        }
        .sheet(isPresented: $openNumberOfCycles) {
            NumberOfCyclesView(selectedNumberOfCycles: $selectedNumberOfCycles)
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
                .font(Font.custom(size: 16, weight: .bold))
            Spacer()
            Button("Done") {
                dismiss()
            }
            .font(Font.custom(size: 16, weight: .bold))
            .foregroundColor(.black)
        }
        .padding()
    }
    
    private var videoPreview: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 220)
            
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
        }
    }
    
    private var timelineSlider: some View {
        VStack(spacing: 4) {
            Slider(value: $currentTime, in: 0...duration)
                .accentColor(Color.darkPurple)
            
            HStack {
                Text(timeString(from: currentTime))
                Spacer()
                Text(timeString(from: duration))
            }
            .foregroundStyle(Color.grayE96)
            .font(Font.custom(size: 15, weight: .regular))
            .padding(.horizontal)
        }
        .padding(.top, 8)
    }
    
    private var settingsSection: some View {
        VStack(spacing: 12) {
            settingRow(title: "Resolution", value: selectedResolution?.value ?? "") {
                openResolution = true
            }
            
            Divider()
                .overlay(Color.gray50)
            
            settingRow(title: "Frame rate", value: "\(frameRate) fps") {
                openFrameRate = true
            }
            
            Divider()
                .overlay(Color.gray50)
            
            settingRow(title: "Number of cycles", value: numberOfCycles) {
                openNumberOfCycles = true
            }
            
            Divider()
                .overlay(Color.gray50)
            
            settingRow(title: "Time range", value: "\(timeString(from: timeRangeStart)) - \(timeString(from: timeRangeEnd)) \(String(format: "%.1fs", timeRangeEnd - timeRangeStart))") {
                // TODO: Open time range editor
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
            RangeSlider(minValue: $timeRangeStart, maxValue: $timeRangeEnd, range: 0...duration)
                .frame(height: 40)
                .padding(.horizontal)
            
            HStack {
                timeAdjusterControl(time: $timeRangeStart)
                Spacer()
                timeAdjusterControl(time: $timeRangeEnd)
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
                time.wrappedValue = min(time.wrappedValue + 0.02, duration)
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
        let ms = Int((seconds - Double(totalSeconds)) * 1000)
        return String(format: "%02d:%02d", min, sec, ms)
    }
    
    private func timeString3Digits(from seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let min = totalSeconds / 60
        let sec = totalSeconds % 60
        let ms = Int((seconds - Double(totalSeconds)) * 1000)
        return String(format: "%02d:%02d:%03d", min, sec, ms)
    }
}

struct RangeSlider: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                let trackWidth = geo.size.width
                let rangeSpan = range.upperBound - range.lowerBound
                
                let lower = CGFloat((minValue - range.lowerBound) / rangeSpan) * trackWidth
                let upper = CGFloat((maxValue - range.lowerBound) / rangeSpan) * trackWidth
                
                let selectedWidth = max(0, upper - lower)
                Capsule()
                    .fill(Color.darkPurple)
                    .frame(width: selectedWidth, height: 4)
                    .offset(x: lower)
                
                let handleSize: CGFloat = 20
                
                Circle()
                    .fill(Color.white)
                    .frame(width: handleSize, height: handleSize)
                    .shadow(radius: 1)
                    .position(x: lower, y: geo.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let clampedX = min(max(value.location.x, 0), upper)
                                let percent = clampedX / trackWidth
                                let newValue = Double(percent) * rangeSpan + range.lowerBound
                                minValue = min(newValue, maxValue)
                            }
                    )
                
                Circle()
                    .fill(Color.white)
                    .frame(width: handleSize, height: handleSize)
                    .shadow(radius: 1)
                    .position(x: upper, y: geo.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let clampedX = max(min(value.location.x, trackWidth), lower)
                                let percent = clampedX / trackWidth
                                let newValue = Double(percent) * rangeSpan + range.lowerBound
                                maxValue = max(newValue, minValue)
                            }
                    )
            }
            .frame(height: 40)
        }
    }
}

#Preview {
    GIFImageEditorView()
}

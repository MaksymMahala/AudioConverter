//
//  FrameRateView.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import SwiftUI

struct FrameRateView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedFrameRate: Int
    
    var isVideo: Bool
    var hasProAccess: Bool

    var frameRates: [Int] {
        isVideo ? [24, 25, 30, 50, 60] : Array(1...30)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Original frame rate")
                        .font(.custom(size: 16, weight: .regular))
                        .foregroundColor(.gray40)
                        .padding(.horizontal)
                        .padding(.top, 10)

                    frameRateRow(option: selectedFrameRate)

                    Text("Setting")
                        .font(.custom(size: 16, weight: .regular))
                        .foregroundColor(.gray40)
                        .padding(.horizontal)

                    ForEach(frameRates, id: \.self) { option in
                        frameRateRow(option: option)
                    }
                }
            }
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
            Text("Frame rate")
                .foregroundStyle(Color.black)
                .font(Font.custom(size: 16, weight: .bold))
            Spacer()
            Button("Done") {
                dismiss()
            }
            .font(.custom(size: 16, weight: .bold))
            .foregroundColor(.black)
        }
        .padding()
    }

    private func frameRateRow(option: Int) -> some View {
        let isProOnly = isVideo && (option == 50 || option == 60)
        let isSelectable = !isProOnly || hasProAccess

        return Button(action: {
            if isSelectable {
                selectedFrameRate = option
            }
        }) {
            VStack {
                HStack(spacing: 12) {
                    Image(systemName: selectedFrameRate == option ? "checkmark.square.fill" : "square")
                        .foregroundColor(selectedFrameRate == option ? Color.darkPurple : Color.gray50)
                        .font(Font.custom(size: 24, weight: .regular))

                    Text("\(option)")
                        .font(Font.custom(size: 16, weight: .regular))
                        .foregroundColor(.gray50)

                    if isProOnly {
                        Text("PRO")
                            .font(.custom(size: 16, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.darkPurple)
                            .foregroundColor(.white)
                            .cornerRadius(17)
                    }

                    Spacer()
                }
                .padding(.horizontal)

                Divider()
                    .frame(height: 0.2)
                    .overlay(Color.gray50)
                    .padding(.horizontal)
                    .padding(.top, 2)
            }
        }
        .disabled(!isSelectable)
    }
}

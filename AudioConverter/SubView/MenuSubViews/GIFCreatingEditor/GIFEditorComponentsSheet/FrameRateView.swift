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
    
    let numberFrameRate: [Int] = Array(1...30)

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
                    
                    ForEach(numberFrameRate, id: \.self) { option in
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
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            Spacer()
            Text("Frame rate")
                .font(.system(size: 17, weight: .semibold))
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
        Button(action: {
            selectedFrameRate = option
        }) {
            VStack {
                HStack {
                    Image(systemName: selectedFrameRate == option ? "checkmark.square.fill" : "square")
                        .foregroundColor(selectedFrameRate == option ? Color.darkPurple : Color.gray50)
                        .font(Font.custom(size: 24, weight: .regular))
                    
                    Text("\(option)")
                        .font(Font.custom(size: 16, weight: .regular))
                        .foregroundColor(.gray50)
                    
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
    }
}

#Preview {
    FrameRateView(selectedFrameRate: .constant(0))
}

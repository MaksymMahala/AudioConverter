//
//  Resolution.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import SwiftUI

struct ResolutionPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedResolution: ResolutionOption?
    
    let originalResolution: ResolutionOption
    let resolutions: [ResolutionOption] = [
        .init(value: "2160*3840", isPro: true),
        .init(value: "1080*1920", isPro: true),
        .init(value: "720*1280", isPro: false),
        .init(value: "480*720", isPro: false),
        .init(value: "480*640", isPro: false),
        .init(value: "3840*2160", isPro: true),
        .init(value: "1920*1080", isPro: true),
        .init(value: "1280*720", isPro: false),
        .init(value: "720*480", isPro: false),
        .init(value: "640*480", isPro: false)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Original video resolution")
                        .font(.custom(size: 16, weight: .regular))
                        .foregroundColor(.gray40)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    resolutionRow(option: ResolutionOption(value: originalResolution.value, isPro: false))
                                        
                    Text("Setting")
                        .font(.custom(size: 16, weight: .regular))
                        .foregroundColor(.gray40)
                        .padding(.horizontal)
                    
                    ForEach(resolutions, id: \.self) { option in
                        resolutionRow(option: option)
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
            Text("Resolution")
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
    
    private func resolutionRow(option: ResolutionOption) -> some View {
        Button(action: {
            if !option.isPro {
                selectedResolution = option
            }
        }) {
            VStack {
                HStack {
                    Image(systemName: selectedResolution == option ? "checkmark.square.fill" : "square")
                        .foregroundColor(selectedResolution == option ? Color.darkPurple : Color.gray50)
                        .font(Font.custom(size: 24, weight: .regular))
                    
                    Text(option.value)
                        .font(Font.custom(size: 16, weight: .regular))
                        .foregroundColor(.gray50)
                    
                    Spacer()
                    
                    if option.isPro {
                        Text("PRO")
                            .font(.custom(size: 16, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.darkPurple)
                            .foregroundColor(.white)
                            .cornerRadius(17)
                    }
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

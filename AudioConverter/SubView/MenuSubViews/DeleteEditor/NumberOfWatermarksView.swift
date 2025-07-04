//
//  NumberOfWatermarksView.swift
//  AudioConverter
//
//  Created by Max on 04.07.2025.
//

import SwiftUI

struct NumberOfWatermarksView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedNumberWaterMarks: Int
    var hasProAccess: Bool
    let numberWaterMarks = [1, 2, 3]
    var body: some View {
        VStack {
            header
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(Array(numberWaterMarks.enumerated()), id: \.1) { index, option in
                        numberWatermarksRow(option: option, isLast: index == numberWaterMarks.count - 1)
                    }
                }
            }
            .padding(.top)
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
            
            Text("Number of watermarks")
                .foregroundStyle(Color.black)
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
    
    private func numberWatermarksRow(option: Int, isLast: Bool) -> some View {
        let isDisabled = isLast && !hasProAccess
        
        return Button(action: {
            if !isDisabled {
                selectedNumberWaterMarks = option
            }
        }) {
            VStack {
                HStack(spacing: 12) {
                    Image(systemName: selectedNumberWaterMarks == option ? "checkmark.square.fill" : "square")
                        .foregroundColor(selectedNumberWaterMarks == option ? Color.darkPurple : Color.gray50)
                        .font(Font.custom(size: 24, weight: .regular))

                    if isLast {
                        Text("Without reflection")
                            .font(.custom(size: 14, weight: .regular))
                            .foregroundColor(.gray50)
                    } else {
                        Text("\(option)")
                            .font(Font.custom(size: 16, weight: .regular))
                            .foregroundColor(.gray50)
                    }

                    if isLast {
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
        .disabled(isDisabled)
    }
}

#Preview {
    NumberOfWatermarksView(selectedNumberWaterMarks: .constant(1), hasProAccess: true)
}

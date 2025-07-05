//
//  NumberOfCyclesView.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import SwiftUI

struct NumberOfCyclesView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedNumberOfCycles: Int
    
    let numberOfCycles: [Int] = [0] + Array(1...10)

    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(numberOfCycles, id: \.self) { option in
                        numberOfCyclesRow(option: option)
                    }
                }
            }
            .padding(.top)
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
            Text("Number of cycles")
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
    
    private func numberOfCyclesRow(option: Int) -> some View {
        Button(action: {
            selectedNumberOfCycles = option
        }) {
            VStack {
                HStack {
                    Image(systemName: selectedNumberOfCycles == option ? "checkmark.square.fill" : "square")
                        .foregroundColor(selectedNumberOfCycles == option ? Color.darkPurple : Color.gray50)
                        .font(Font.custom(size: 24, weight: .regular))
                    
                    Text(option == 0 ? "Endless looping" : "\(option)")
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
    NumberOfCyclesView(selectedNumberOfCycles: .constant(0))
}

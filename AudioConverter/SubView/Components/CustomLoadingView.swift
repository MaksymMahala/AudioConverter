//
//  CustomLoadingView.swift
//  AudioConverter
//
//  Created by Max on 02.07.2025.
//

import SwiftUI

struct CustomLoadingView: View {
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Loading...")
                    .font(Font.custom(size: 28, weight: .bold))
                    .foregroundColor(Color.darkPurple)
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 150, height: 5)
                        .foregroundColor(Color.white)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: progress * 150, height: 8)
                        .foregroundColor(Color.primary130)
                        .animation(.easeInOut(duration: 1), value: progress)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.darkPurple, lineWidth: 1)
                }
            }
        }
        .onAppear {
            startAnimating()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func startAnimating() {
        timer?.invalidate()
        progress = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            withAnimation {
                progress += 0.01
                if progress >= 1.0 {
                    progress = 0.0
                }
            }
        }
    }
}

#Preview {
    CustomLoadingView()
}

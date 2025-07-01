//
//  LaunchView.swift
//  AudioConverter
//
//  Created by Max on 29.06.2025.
//

import SwiftUI

struct LaunchView: View {
    @State private var animate = false
    @State private var showNextView = false
    @State private var rotation = false
    @State private var opacity: Double = 0.5
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some View {
        ZStack {
            if showNextView {
                if isLoggedIn {
                    CustomTabBar()
                } else {
                    OnboardingView(showOnboarding: $showNextView)
                }
            } else {
                VStack {
                    Image(.logoIcon)
                        .resizable()
                        .frame(width: 120, height: 120)
                        .opacity(opacity)
                        .scaleEffect(animate ? 1.1 : 0.9)
                        .rotationEffect(.degrees(animate ? 5 : -5))
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
                        .animation(.easeInOut(duration: 1.5), value: opacity)
                }
            }
        }
        .onAppear {
            opacity = 1.0
            animate = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation {
                    showNextView = true
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LaunchView()
}


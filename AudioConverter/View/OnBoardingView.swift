//
//  OnBoardingView.swift
//  AudioConverter
//
//  Created by Max on 29.06.2025.
//

import SwiftUI
import StoreKit

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State var selectedViewIndex = 0
    
    let purchaseManager = PurchaseManager.instance
    
    var body: some View {
        switch selectedViewIndex {
        case 0:
            SubOnboardingView(showOnboarding: $showOnboarding, selectedViewIndex: $selectedViewIndex, title: "Welcome to the MP3 convector app", subTitle: "Work with audio, video, images in one app", banerImage: .bannerOnboarding01, icon: .loader1)
        case 1:
            SubOnboardingView(showOnboarding: $showOnboarding, selectedViewIndex: $selectedViewIndex, title: "Convert video & extract audio", subTitle: "A convenient way to get audio in three taps", banerImage: .bannerOnboarding02, icon: .loader2)
        case 2:
            SubOnboardingView(showOnboarding: $showOnboarding, selectedViewIndex: $selectedViewIndex, title: "Reviews from users who trust", subTitle: "Use the app to the fullest and leave your personal feedback", banerImage: .bannerOnboarding03, icon: .loader3)
                .onAppear {
                    purchaseManager.setDevice()
                }
        case 3:
            SubOnboardingView(showOnboarding: $showOnboarding, selectedViewIndex: $selectedViewIndex, title: "Create GIFs & convert images", subTitle: "Create your GIFs & save converted files and images to custom folders in the app", banerImage: .bannerOnboarding05, icon: .loader4)
                .onAppear {
                    showReview()
                }
        case 4:
            SubOnboardingView(showOnboarding: $showOnboarding, selectedViewIndex: $selectedViewIndex, title: "Convert, edit & store securely", subTitle: "Create a personal folder with limited access and securely store documents", banerImage: .bannerOnboarding06, icon: .loader5)
        case 5:
            PayWallView(showOnboarding: $showOnboarding)
        default:
            EmptyView()
        }
    }
    
    private func showReview() {
        guard let scene = UIApplication.shared.foregroundActiveScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(false))
}



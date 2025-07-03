//
//  MenuView.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct MenuView: View {
    @StateObject private var tabViewModel = MediaTabViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HeaderWithPay(title: "Convert")
                    MediaTabSelector(viewModel: tabViewModel)
                        .padding(.top)
                    ScrollView {
                        VStack {
                            switch tabViewModel.selectedTab {
                            case .video:
                                VideoToolsView(isLoadingVideo: $tabViewModel.isLoading)
                            case .audio:
                                AudioToolsView(isLoadingAudio: $tabViewModel.isLoading)
                            case .image:
                                ImageToolsView(isLoadingImage: $tabViewModel.isLoading)
                            }
                        }
                        .padding(.bottom)
                        .padding(.top, 16)
                    }
                }
                
                if tabViewModel.isLoading {
                    CustomLoadingView()
                }
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

#Preview {
    MenuView()
}

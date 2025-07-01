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
            VStack {
                HeaderWithPay(title: "Convert")
                MediaTabSelector(viewModel: tabViewModel)
                    .padding(.top)
                ScrollView {
                    VStack {
                        switch tabViewModel.selectedTab {
                        case .video:
                            VideoToolsView()
                        case .audio:
                            AudioToolsView()
                        case .image:
                            ImageToolsView()
                        }
                    }
                    .padding(.bottom)
                    .padding(.top, 16)
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

//
//  SettingsView.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .foregroundStyle(Color.gray60)
                .font(Font.custom(size: 20, weight: .bold))
                .bold()
                .padding(.top, 20)
            
            ScrollView(showsIndicators: false) {
                if !PurchaseManager.instance.userPurchaseIsActive {
                    PremiumBannerView()
                        .padding(.horizontal)
                        .padding(.vertical)
                }
                
                if PurchaseManager.instance.userPurchaseIsActive {
                    VStack(spacing: 2) {
                        ForEach(Array(viewModel.optionsSubscribed.enumerated()), id: \.element.id) { index, option in
                            SettingsRow(option: option)
                                .padding(.top, 7)
                            
                            if index < viewModel.options.count - 1 {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .background(Color.grayF7F8FA)
                    .cornerRadius(16)
                    .padding()
                } else {
                    VStack(spacing: 2) {
                        ForEach(Array(viewModel.options.enumerated()), id: \.element.id) { index, option in
                            SettingsRow(option: option)
                                .padding(.top, 7)
                            
                            if index < viewModel.options.count - 1 {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom)
                    .background(Color.grayF7F8FA)
                    .cornerRadius(16)
                    .padding()
                }
                Spacer()
            }
            .padding(.bottom)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    SettingsView()
}

//
//  PremiumBannerView.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import SwiftUI

struct PremiumBannerView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(.settingBanner)
                .resizable()
                .scaledToFit()
                .cornerRadius(20)
                .frame(height: 200)
            
            Text("Unlock all features")
                .font(Font.custom(size: 20, weight: .bold))
                .foregroundColor(Color.gray50)
            
            Button(action: {
                
            }) {
                Text("Try now")
                    .foregroundColor(.white)
                    .font(Font.custom(size: 16, weight: .regular))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.darkPurple)
                    .cornerRadius(25)
            }
        }
        .padding()
        .padding(.bottom)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

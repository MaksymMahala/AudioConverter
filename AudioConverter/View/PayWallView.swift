//
//  PayWallView.swift
//  AudioConverter
//
//  Created by Max on 29.06.2025.
//

import SwiftUI

struct PayWallView: View {
    @StateObject private var viewModel = PayWallViewModel()
    @Binding var showOnboarding: Bool
    var subTitle = "3-day trial, then $3.50/week for full access, or proceed with limited version"
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            HStack {
                Button {
                    withAnimation {
                        showOnboarding = false
                    }
                } label: {
                    Image(.iconoirXmark)
                }
                
                Spacer()
                
                Image(.loader6)
            }
            .padding(.horizontal)
            
            Image(.bannerFreeAcces)
                .resizable()
                .scaledToFit()
                .frame(height: 500)
            
            Text("MP3 convector application")
                .foregroundStyle(Color.darkBlueD90)
                .font(Font.titleMori32)
                .lineLimit(2)
            
            VStack(spacing: 9) {
                Text("3-day trial, then $7.99/week for full ")

                HStack(spacing: 0) {
                    Text("access, or")
                    Button(action: {
                        UserDefaultsManager.shared.isLoggedIn = true
                    }) {
                        Text(" proceed with limited version")
                            .underline()
                    }
                    .buttonStyle(.plain)
                }
            }
            .font(.bodyMori)
            .foregroundStyle(Color.grayE96)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)

            Button {
                withAnimation {
                    if let product = viewModel.selectedProduct {
                        viewModel.purchaseProduct(product.productId) {
                            UserDefaultsManager.shared.isLoggedIn = true
                        }
                    }
                }
            } label: {
                Text("Next")
                    .foregroundStyle(Color.white5FF)
                    .font(Font.bodyMori)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.darkPurple)
                    .cornerRadius(30)
                    .padding(.horizontal)
            }
            
            TermsOfUseSection(
                privacyPolicyAction: {
                
            }, restoreAction: {
                viewModel.restorePurchases()
            }, termsOfUseAction: {
                
            })
        }
        .multilineTextAlignment(.center)
        .onAppear {
            viewModel.purchaseManager.activate()
            Task {
                await viewModel.loadPaywallSub()
            }
        }
    }
}

#Preview {
    PayWallView(showOnboarding: .constant(false))
}

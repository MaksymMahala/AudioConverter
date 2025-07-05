//
//  SubsView.swift
//  AudioConverter
//
//  Created by Max on 05.07.2025.
//

import SwiftUI
import ApphudSDK

struct SubsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SubsViewModel()
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 30) {
                header
                            
                bodyIcon
                
                Text("Unlock Premium Access")
                    .font(Font.titleMori32)
                    .foregroundColor(.darkBlueD90)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            
            productSelection
            
            trialInfo
            
            continueButton
            
            footerLinks
        }
        .onAppear {
            viewModel.purchaseManager.activate()
            viewModel.loadProducts()
        }
    }
    
    private var header: some View {
        HStack {
            Button {
                withAnimation {
                    dismiss()
                }
            } label: {
                Image(.iconoirXmark)
            }
            
            Spacer()
            
            Image(.loader6)
        }
        .padding()
    }
    
    private var bodyIcon: some View {
        VStack {
            HStack {
                Image(.arrowRightSubs)
                
                Image(.subsList)
                    .padding(.leading)
                
                Image(.arrowLeftSubs)

                Spacer()
            }
            
            Image(.buttonsSubs)
        }
    }
    
    private var productSelection: some View {
        HStack(spacing: 12) {
            ForEach(viewModel.products, id: \.productId) { product in
                productButton(for: product)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func productButton(for product: ApphudProduct) -> some View {
        Button {
            viewModel.selectedProductID = product
        } label: {
            SubscriptionOptionView(
                title: subscriptionType(for: product),
                price: PriceFormatterManager.shared.formatPrice(product.skProduct?.price, locale: product.skProduct?.priceLocale),
                perDay: PurchaseManager.instance.calculatePerDayPrice(for: product),
                isHighlighted: viewModel.selectedProductID == product
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func subscriptionType(for product: ApphudProduct) -> String {
        guard let skProduct = product.skProduct,
              let period = skProduct.subscriptionPeriod else {
            return fallbackSubscriptionType(from: product.name)
        }

        switch period.unit {
        case .week:
            return "Weekly"
        case .month:
            return "Monthly"
        case .year:
            return "Yearly"
        case .day:
            return period.numberOfUnits == 7 ? "Weekly" : "Daily"
        default:
            return fallbackSubscriptionType(from: product.name)
        }
    }
    
    private func fallbackSubscriptionType(from name: String?) -> String {
        guard let name = name?.lowercased() else { return "Unknown" }

        if name.contains("weekly") { return "Weekly" }
        if name.contains("monthly") { return "Monthly" }
        if name.contains("yearly") { return "Yearly" }

        return "Unknown"
    }
    
    private var trialInfo: some View {
        Text("3-day trial - Secured by the App Store. Cancel anytime.")
            .font(Font.custom(size: 12, weight: .regular))
            .foregroundColor(.gray50)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    private var continueButton: some View {
        Button {
            withAnimation {
                viewModel.purchaseProduct {
                    dismiss()
                }
            }
        } label: {
            Text("Continue")
                .font(Font.custom(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.darkPurple)
                .cornerRadius(25)
        }
        .padding(.horizontal)
    }
    
    private var footerLinks: some View {
        HStack {
            Button { } label: { Text("Privacy Policy") }
            Spacer()
            Divider().frame(width: 1, height: 13).overlay(Color.gray)
            Spacer()
            Button {
                viewModel.restorePurchases()
            } label: {
                Text("Restore")
            }
            Spacer()
            Divider().frame(width: 1, height: 13).overlay(Color.gray)
            Spacer()
            Button { } label: { Text("Terms of use") }
        }
        .font(Font.custom(size: 12, weight: .regular))
        .foregroundColor(.gray60)
        .padding(.horizontal, 30)
        .padding(.bottom)
    }
}

#Preview {
    SubsView()
}

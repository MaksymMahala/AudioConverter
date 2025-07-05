//
//  SubsViewModel.swift
//  AudioConverter
//
//  Created by Max on 05.07.2025.
//

import Foundation
import ApphudSDK

@MainActor
final class SubsViewModel: ObservableObject {
    @Published var selectedImageIndex = 0
    @Published var selectedProductID: ApphudProduct?
    @Published var isLoading = false
    @Published var purchaseMessage: String?

    var purchaseManager = PurchaseManager.instance

    @Published var products: [ApphudProduct] = []
    
    func purchaseProduct(completion: @escaping () -> Void) {
        guard let productId = selectedProductID?.productId else {
            self.purchaseMessage = "Product not selected"
            completion()
            return
        }
        
        isLoading = true
        purchaseManager.purchase(productId) { errorMessage, success in
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.purchaseMessage = "Purchase successful!"
                } else {
                    self.purchaseMessage = errorMessage ?? "Purchase failed"
                }
                completion()
            }
        }
    }
    
    func loadProducts() {
        purchaseManager.getSubscriptions(paywallId: "paywallInside") { success in
            DispatchQueue.main.async {
                if success {
                    self.products = self.purchaseManager.products
                } else {
                    self.purchaseMessage = "Failed to load products."
                }
            }
        }
    }
    
    func restorePurchases() {
        purchaseManager.restorePurchases { success in
            print(success ? "Restored successfully." : "Restore failed.")
        }
    }
}

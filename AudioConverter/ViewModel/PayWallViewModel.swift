//
//  PayWallViewModel.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI
//import ApphudSDK

//class PayWallViewModel: ObservableObject {
//    @Published var selectedProduct: ApphudProduct?
//    let purchaseManager = PurchaseManager.instance
//
//    @MainActor
//    func loadPaywallSub() async {
//        await withCheckedContinuation { continuation in
//            purchaseManager.getSubscriptions(paywallId: "onboardPaywall") { success in
//                if success {
//                    if let weekProduct = self.purchaseManager.products.first(where: { $0.productId.lowercased().contains("week") }) {
//                        DispatchQueue.main.async {
//                            self.selectedProduct = weekProduct
//                        }
//                    }
//                }
//                continuation.resume()
//            }
//        }
//    }
//       
//    func purchaseProduct(_ productID: String, completion: @escaping () -> Void) {
//        Task {
//            await purchaseManager.purchase(productID) { errorMessage, success in
//                DispatchQueue.main.async {
//                    if success {
//                        print("Purchase successful!")
//                        completion()
//                    } else {
//                        print("Purchase failed: \(String(describing: errorMessage))")
//                        completion()
//                    }
//                }
//            }
//        }
//    }
//       
//    @MainActor
//    func restorePurchases() {
//        purchaseManager.restorePurchases { success in
//            print(success ? "Restored successfully." : "Restore failed.")
//        }
//    }
//}

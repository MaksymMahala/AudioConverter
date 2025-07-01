//
//  PurchaseManager.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import Foundation
import ApphudSDK
import SwiftUI
import AdSupport
import AppTrackingTransparency
import StoreKit

final class PurchaseManager {
    
    // MARK: - Properties
    @AppStorage("userPurchaseIsActive_Locator0301") var userPurchaseIsActive: Bool = false
    @AppStorage("shouldShowPromotion_Locator0301") var shouldShowPromotion = true
    static let instance = PurchaseManager()
    var products: [ApphudProduct] = []
    
    private init() {}
    
    // MARK: - Methods
    @MainActor func activate() {
        Apphud.start(apiKey: Constants.apiKey)
        Apphud.setDeviceIdentifiers(idfa: nil, idfv: UIDevice.current.identifierForVendor?.uuidString)
    }
    
    func setDevice() {
        requestTrackingPermission()
    }
    
    @MainActor func purchase(_ productID: String, completion: @escaping (String?, Bool) -> ()) {
        Apphud.purchase(productID) { result in
            if result.success {
                self.userPurchaseIsActive = true
                self.shouldShowPromotion = false
                completion(nil, true)
            } else if let subscription = result.subscription, subscription.isActive() {
                self.userPurchaseIsActive = Apphud.hasActiveSubscription()
                self.shouldShowPromotion = false
                completion(nil, true)
            } else {
                completion(nil, false)
            }
        }
    }
    
    @MainActor func restorePurchases(completion: @escaping (Bool) -> ()) {
        Apphud.restorePurchases { _, _, _ in
            if Apphud.hasActiveSubscription() {
                self.userPurchaseIsActive = Apphud.hasActiveSubscription()
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    @MainActor func getSubscriptions(paywallId: String, completion: @escaping (Bool) -> ()) {
        checkSubscription()
        Apphud.paywallsDidLoadCallback { paywalls, error in
            
            if let error = error {
                print("Error loading paywalls: \(error.localizedDescription)")
                completion(false)
                return
            }
            if paywalls.count == 0 {
                completion(false)
            } else {
                if let paywall = paywalls.first(where: {$0.identifier == paywallId}) {
                    self.products = paywall.products
                    self.products.forEach { product in
                        print("Product: \(product.skProduct?.localizedTitle ?? "")")
                    }
                }
                completion(true)
            }
        }
    }
    
    func checkSubscription() {
        userPurchaseIsActive = Apphud.hasActiveSubscription()
    }
    
   func requestTrackingPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // The user authorized access to IDFA
                    print("Tracking authorized. IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                    self.fetchIDFA()
                case .denied, .restricted, .notDetermined:
                    // The user denied or restricted access, or the authorization is not determined yet
                    print("Tracking denied or restricted")
                @unknown default:
                    break
                }
            }
        }
    }
    
    func fetchIDFA() {
        if #available(iOS 14.5, *) {
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    guard status == .authorized else {return}
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    Apphud.setDeviceIdentifiers(idfa: idfa, idfv: UIDevice.current.identifierForVendor?.uuidString)
                }
            }
        }
    }
    
    @available(iOS, deprecated: 18.0)
    func calculatePerDayPrice(for product: ApphudProduct) -> String {
        guard let skProduct = product.skProduct,
              let period = skProduct.subscriptionPeriod else {
            return ""
        }
        
        let price = skProduct.price.doubleValue
        let durationInDays: Double = {
            switch period.unit {
            case .day:
                return Double(period.numberOfUnits)
            case .week:
                return Double(period.numberOfUnits * 7)
            case .month:
                return Double(period.numberOfUnits * 30)
            case .year:
                return Double(period.numberOfUnits * 365)
            @unknown default:
                return 1
            }
        }()
        
        guard durationInDays > 0 else { return "" }
        
        let perDay = price / durationInDays
        return String(format: "%.2f US$/day", perDay)
    }
}

//
//  PriceFormatterManager.swift
//  AudioConverter
//
//  Created by Max on 05.07.2025.
//

import Foundation

final class PriceFormatterManager {
    static let shared = PriceFormatterManager()
    private init() {}

    func formatPrice(_ price: NSDecimalNumber?, locale: Locale?) -> String {
        guard let price = price else { return "—" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale ?? Locale.current
        return formatter.string(from: price) ?? "—"
    }
}

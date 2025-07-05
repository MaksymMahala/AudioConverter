//
//  SubscriptionOptionView.swift
//  AudioConverter
//
//  Created by Max on 05.07.2025.
//

import Foundation
import SwiftUI

struct SubscriptionOptionView: View {
    var title: String
    var price: String
    var perDay: String
    var isHighlighted: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .foregroundColor(Color.black)
                .font(Font.custom(size: 16, weight: .bold))
            Text(price)
                .foregroundColor(Color.gray50)
                .font(Font.custom(size: 16, weight: .regular))
            Text(perDay)
                .foregroundColor(Color.gray40)
                .font(Font.custom(size: 12, weight: .regular))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            Color.clear
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isHighlighted ? Color.black : Color.gray40, lineWidth: 2)
        )
        .cornerRadius(12)
    }
}

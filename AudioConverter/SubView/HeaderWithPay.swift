//
//  HeaderWithPay.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct HeaderWithPay: View {
    var title: String
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.black)
                .font(Font.custom(size: 20, weight: .bold))
            
            Spacer()
            
            Button {
                
            } label: {
                HStack {
                    Image(.premiumIcon)
                    
                    Text("PRO")
                        .foregroundStyle(Color.white)
                        .font(Font.custom(size: 16, weight: .medium))
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 5)
                .frame(width: 120)
                .background(Color.darkPurple)
                .cornerRadius(30)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    HeaderWithPay(title: "Convert")
}

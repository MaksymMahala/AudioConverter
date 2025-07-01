//
//  TermsOfUseSection.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct TermsOfUseSection: View {
    var privacyPolicyAction: () -> ()
    var restoreAction: () -> ()
    var termsOfUseAction: () -> ()

    var body: some View {
        HStack {
            Button {
                withAnimation {
                    privacyPolicyAction()
                }
            } label: {
                Text("Privacy Policy")
                    .foregroundStyle(Color.lightBlack529)
                    .font(Font.custom(size: 12, weight: .regular))
            }
            
            Spacer()
            
            Divider()
                .frame(width: 1)
                .frame(height: 15)
                .overlay(Color.lightBlack529)
            
            Spacer()

            Button {
                withAnimation {
                    restoreAction()
                }
            } label: {
                Text("Restore")
                    .foregroundStyle(Color.lightBlack529)
                    .font(Font.custom(size: 12, weight: .regular))
            }
            
            Spacer()
            
            Divider()
                .frame(width: 1)
                .frame(height: 15)
                .overlay(Color.lightBlack529)
            
            Spacer()
            
            Button {
                withAnimation {
                    termsOfUseAction()
                }
            } label: {
                Text("Terms of Use")
                    .foregroundStyle(Color.lightBlack529)
                    .font(Font.custom(size: 12, weight: .regular))
            }
        }
        .padding(.horizontal, 30)
    }
}

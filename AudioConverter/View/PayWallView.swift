//
//  PayWallView.swift
//  AudioConverter
//
//  Created by Max on 29.06.2025.
//

import SwiftUI

struct PayWallView: View {
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
            
            HStack {
                Button {
                    withAnimation {
                        
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
                        
                    }
                } label: {
                    Text("Terms of Use")
                        .foregroundStyle(Color.lightBlack529)
                        .font(Font.custom(size: 12, weight: .regular))
                }
            }
            .padding(.horizontal, 30)
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    PayWallView(showOnboarding: .constant(false))
}

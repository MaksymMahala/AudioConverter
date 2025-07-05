//
//  SubOnboardingView.swift
//  AudioConverter
//
//  Created by Max on 29.06.2025.
//

import SwiftUI

struct SubOnboardingView: View {
    @Binding var selectedViewIndex: Int
    var title: String
    var subTitle: String
    var banerImage: ImageResource
    var icon: ImageResource
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Spacer()
            HStack {
                Button {
                    withAnimation {
                        if selectedViewIndex != 0 {
                            selectedViewIndex -= 1
                        }
                    }
                } label: {
                    Image(.iconoirXmark)
                }
                
                Spacer()
                
                Image(icon)
            }
            .padding()
            
            Image(banerImage)
                .resizable()
                .scaledToFit()
                .frame(height: 450)
            
            Text(title)
                .foregroundStyle(Color.darkBlueD90)
                .font(Font.titleMori32)
                .frame(height: 100)
                .lineLimit(2)
            
            let isLongSubtitle = subTitle.count > 50

            Text(subTitle)
                .foregroundStyle(Color.grayE96)
                .font(.bodyMori)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: isLongSubtitle ? UIScreen.main.bounds.width * 0.7 : UIScreen.main.bounds.width * 0.5)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                withAnimation {
                    if selectedViewIndex < 5 {
                        selectedViewIndex += 1
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
                
            }, termsOfUseAction: {
                
            })
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    SubOnboardingView(selectedViewIndex: .constant(0), title: "Welcome to the MP3 convector app", subTitle: "Work with audio, video, images in one app", banerImage: .bannerOnboarding01, icon: .loader1)
}

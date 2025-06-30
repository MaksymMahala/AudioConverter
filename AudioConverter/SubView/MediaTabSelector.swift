//
//  MediaTabSelector.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct MediaTabSelector: View {
    @ObservedObject var viewModel: MediaTabViewModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MediaTab.allCases, id: \.self) { tab in
                Button(action: {
                    viewModel.selectedTab = tab
                }) {
                    Text(tab.rawValue)
                        .font(Font.custom(size: 16, weight: .regular))
                        .foregroundColor(viewModel.selectedTab == tab ? Color.darkBlueD90 : Color.gray50)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            viewModel.selectedTab == tab ?
                                Color.secondary0110 :
                                Color.grayF7F8FA
                        )
                        .cornerRadius(25)
                }
            }
        }
        .padding(4)
        .background(Color(UIColor.grayF7F8FA))
        .cornerRadius(25)
        .padding(.horizontal)
    }
}

//
//  CustomTabBar.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct CustomTabBar: View {
    @State private var selectedTab: Tab = .convert

    enum Tab {
        case convert, files, works, settings
    }

    var body: some View {
        VStack {
            switch selectedTab {
            case .convert:
                MenuView()
            case .files:
                EmptyView()
            case .works:
                EmptyView()
            case .settings:
                EmptyView()
            }

            Spacer()

            HStack {
                tabButton(tab: .convert, selectedImage: "refresh-icon-active", unselectedImage: "refresh-icon-unactive", title: "Convert")
                tabButton(tab: .files, selectedImage: "folder-icon-active", unselectedImage: "folder-icon-unactive", title: "Files")
                tabButton(tab: .works, selectedImage: "file-icon-active", unselectedImage: "file-icon-unactive", title: "Works")
                tabButton(tab: .settings, selectedImage: "settings-icon-active", unselectedImage: "settings-icon-unactive", title: "Settings")
            }
            .frame(height: 60)
            .background(Color.white)
            .padding(.bottom)
        }
        .navigationBarBackButtonHidden()
    }

    private func tabButton(tab: Tab, selectedImage: String, unselectedImage: String, title: String) -> some View {
        let isSelected = selectedTab == tab

        return VStack {
            Image(isSelected ? selectedImage : unselectedImage)
                .resizable()
                .frame(width: 24, height: 24)

            Text(title)
                .font(Font.custom(size: 12, weight: .regular))
                .foregroundColor(isSelected ? Color.darkPurple : Color.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .onTapGesture {
            selectedTab = tab
        }
    }
}

#Preview {
    CustomTabBar()
}

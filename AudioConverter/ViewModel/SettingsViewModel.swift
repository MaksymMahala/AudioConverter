//
//  SettingsViewModel.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var options: [SettingsOption] = [
        SettingsOption(icon: "iconoir_lock", title: "Privacy policy"),
        SettingsOption(icon: "iconoir_empty-page", title: "Terms of Use"),
        SettingsOption(icon: "iconoir_share-android", title: "Share App"),
        SettingsOption(icon: "iconoir_thumbs-up", title: "Rate Us"),
        SettingsOption(icon: "iconoir_mail", title: "Contact Us")
    ]
    
    @Published var optionsSubscribed: [SettingsOption] = [
        SettingsOption(icon: "iconoir_settings", title: "Subscriptions"),
        SettingsOption(icon: "iconoir_lock", title: "Privacy policy"),
        SettingsOption(icon: "iconoir_empty-page", title: "Terms of Use"),
        SettingsOption(icon: "iconoir_share-android", title: "Share App"),
        SettingsOption(icon: "iconoir_thumbs-up", title: "Rate Us"),
        SettingsOption(icon: "iconoir_mail", title: "Contact Us")
    ]
}

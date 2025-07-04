//
//  CleanerApp.swift
//  Cleaner
//
//  Created by Max on 29.06.2025.
//

import SwiftUI

@main
struct CleanerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        WebpCoder.registerWebPCoder()
    }
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
        }
    }
}

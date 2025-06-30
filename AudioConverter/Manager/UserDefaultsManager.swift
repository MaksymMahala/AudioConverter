//
//  UserDefaultsManager.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import Foundation

struct UserDefaultsManager {
    private static let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let isLoggedIn = "isLoggedIn"
    }
    
    // MARK: - Launch Tracking
    static var hasLaunchedBefore: Bool {
        get { defaults.bool(forKey: Keys.hasLaunchedBefore) }
        set { defaults.set(newValue, forKey: Keys.hasLaunchedBefore) }
    }
    
    // MARK: - Authentication State
    static var isLoggedIn: Bool {
        get { defaults.bool(forKey: Keys.isLoggedIn) }
        set { defaults.set(newValue, forKey: Keys.isLoggedIn) }
    }
}


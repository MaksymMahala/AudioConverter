//
//  UserDefaultsManager.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Keys
    private enum Keys {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let isLoggedIn = "isLoggedIn"
        static let playlistsKey = "SavedPlaylists"
        static let mappingKey = "playlistsMapping"
    }
    
    var hasLaunchedBefore: Bool {
        get { defaults.bool(forKey: Keys.hasLaunchedBefore) }
        set { defaults.set(newValue, forKey: Keys.hasLaunchedBefore) }
    }

    var isLoggedIn: Bool {
        get { defaults.bool(forKey: Keys.isLoggedIn) }
        set { defaults.set(newValue, forKey: Keys.isLoggedIn) }
    }
    
    var defaultPlaylists: [String] {
        return ["My Favorites", "Hidden folder"]
    }
    
    // MARK: - Playlists
    func savePlaylists(_ playlists: [String]) {
        defaults.set(playlists, forKey: Keys.playlistsKey)
    }
    
    func loadPlaylists() -> [String] {
        var loaded = defaults.stringArray(forKey: Keys.playlistsKey) ?? []
        
        for name in defaultPlaylists where !loaded.contains(name) {
            loaded.insert(name, at: 0)
        }
        
        return loaded
    }
    
    // MARK: - Mapping: Playlist → [FileID]
    func getFileIDs(for playlist: String) -> [String] {
        let dict = defaults.dictionary(forKey: Keys.mappingKey) as? [String: [String]] ?? [:]
        return dict[playlist] ?? []
    }
    
    func addFile(id: String, to playlist: String) {
        var dict = defaults.dictionary(forKey: Keys.mappingKey) as? [String: [String]] ?? [:]
        var ids = dict[playlist] ?? []
        
        if !ids.contains(id) {
            ids.append(id)
        }
        
        dict[playlist] = ids
        defaults.set(dict, forKey: Keys.mappingKey)
    }
}


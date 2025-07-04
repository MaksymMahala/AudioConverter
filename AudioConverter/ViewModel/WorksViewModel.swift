//
//  WorksViewModel.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import Foundation
import SwiftUI

class WorksViewModel: ObservableObject {
    @Published var savedFiles: [SavedFileEntity] = []
    @Published var selectedFile: SavedFileEntity?
    @Published var alertType: WorksAlertType? = nil
    @Published var showCreatePlaylistView = false
    @Published var newPlaylistName: String = ""
    @Published var playlists: [String] = []
    @Published var showFolderPickerSheet: Bool = false
    @Published var selectedTab: String = "Video" {
        didSet {
            loadFiles()
        }
    }
    
    init() {
        loadFiles()
        loadPlaylists()
    }

    func loadFiles() {
        savedFiles = CoreDataManager.shared.fetchFiles(ofType: selectedTab)
    }
    
    func deleteFile(file: SavedFileEntity) {
        CoreDataManager.shared.deleteSavedFile(file)
    }
    
    func last14Characters(of name: String) -> String {
        return String(name.suffix(14))
    }
    
    func iconNameForType(_ type: String?) -> String {
        switch type {
        case "Video": return "video.fill"
        case "Audio": return "waveform"
        case "Image": return "photo"
        default: return "doc"
        }
    }
    
    func createNewPlaylist() {
        let trimmed = newPlaylistName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let defaultCount = 2
        playlists.insert(trimmed, at: min(defaultCount, playlists.count))
        
        savePlaylists()
        newPlaylistName = ""
    }

    private func savePlaylists() {
        UserDefaults.standard.set(playlists, forKey: "SavedPlaylists")
    }

    func loadPlaylists() {
        var loaded = UserDefaults.standard.stringArray(forKey: "SavedPlaylists") ?? []
        
        let defaults = ["My Favorites", "Hidden folder"]
        for defaultName in defaults {
            if !loaded.contains(defaultName) {
                loaded.insert(defaultName, at: 0)
            }
        }

        playlists = loaded
    }
    
    func addFile(_ file: SavedFileEntity, toPlaylist playlistName: String) {
        let defaults = UserDefaults.standard
        let fileID = file.id?.uuidString ?? UUID().uuidString

        var playlists = defaults.dictionary(forKey: "playlistsMapping") as? [String: [String]] ?? [:]

        var filesInPlaylist = playlists[playlistName] ?? []
        if !filesInPlaylist.contains(fileID) {
            filesInPlaylist.append(fileID)
        }

        playlists[playlistName] = filesInPlaylist
        defaults.set(playlists, forKey: "playlistsMapping")

        print("Added \(file.fileName ?? "") to \(playlistName)")
    }
    
    func getFileIDs(forPlaylist name: String) -> [String] {
        let defaults = UserDefaults.standard
        let playlists = defaults.dictionary(forKey: "playlistsMapping") as? [String: [String]] ?? [:]
        return playlists[name] ?? []
    }
    
    func iconAndColor(for playlist: String) -> (ImageResource, Color) {
        switch playlist {
        case "My Favorites":
            return (.iconoirHeartSolid, .primary130)
        case "Hidden folder":
            return (.iconoirFaceId, .gray20)
        default:
            return (.iconoirFolder, .gray20)
        }
    }
}

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
    @Published var showSubsView: Bool = false
    @Published var selectedTab: String = "Video" {
        didSet {
            loadFiles()
        }
    }
    
    private let defaultsManager = UserDefaultsManager.shared

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

        let defaultCount = defaultsManager.defaultPlaylists.count
        playlists.insert(trimmed, at: min(defaultCount, playlists.count))
        defaultsManager.savePlaylists(playlists)

        newPlaylistName = ""
    }

    func loadPlaylists() {
        playlists = defaultsManager.loadPlaylists()
    }

    func addFile(_ file: SavedFileEntity, toPlaylist playlistName: String) {
        let id = file.id?.uuidString ?? UUID().uuidString
        defaultsManager.addFile(id: id, to: playlistName)
        print("Added \(file.fileName ?? "") to \(playlistName)")
    }

    func getFileIDs(forPlaylist name: String) -> [String] {
        return defaultsManager.getFileIDs(for: name)
    }

    func iconAndColor(for playlist: String) -> (ImageResource, Color) {
        switch playlist {
        case "My Favorites": return (.iconoirHeartSolid, .primary130)
        case "Hidden folder": return (.iconoirFaceId, .gray20)
        default: return (.iconoirFolder, .gray20)
        }
    }
}

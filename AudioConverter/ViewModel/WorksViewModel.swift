//
//  WorksViewModel.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import Foundation

class WorksViewModel: ObservableObject {
    @Published var savedFiles: [SavedFileEntity] = []
    @Published var showDeleteAlert = false
    @Published var selectedFile: SavedFileEntity?
    @Published var selectedTab: String = "Video" {
        didSet {
            loadFiles()
        }
    }
    
    init() {
        loadFiles()
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
}

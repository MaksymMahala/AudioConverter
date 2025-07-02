//
//  WorksViewModel.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import Foundation

class WorksViewModel: ObservableObject {
    @Published var savedFiles: [SavedFileEntity] = []
    @Published var selectedTab = "Video"
    @Published var showDeleteAlert = false
    @Published var selectedFile: SavedFileEntity?

    init() {
        loadSavedFiles()
    }

    func loadSavedFiles() {
        savedFiles = CoreDataManager.shared.fetchSavedFiles()
    }
    
    func deleteFile(file: SavedFileEntity) {
        CoreDataManager.shared.deleteSavedFile(file)
    }
    
    func last14Characters(of name: String) -> String {
        return String(name.suffix(14))
    }
}

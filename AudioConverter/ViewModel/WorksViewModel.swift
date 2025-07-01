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

    init() {
        loadSavedFiles()
    }

    func loadSavedFiles() {
        savedFiles = CoreDataManager.shared.fetchSavedFiles()
    }
}

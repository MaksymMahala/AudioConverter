//
//  CoreDataManager.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AudioConverterDB")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { desc, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Save context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Core Data save error: \(error)")
            }
        }
    }

    // MARK: - Fetch SavedFileEntity
    func fetchSavedFiles() -> [SavedFileEntity] {
        let request: NSFetchRequest<SavedFileEntity> = SavedFileEntity.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }

    // MARK: - Add new SavedFileEntity
    func addSavedFile(fileURL: URL, fileName: String, type: String = "audio", fileSize: UInt64, duration: String) {
        let savedFile = SavedFileEntity(context: context)
        savedFile.id = UUID()
        savedFile.fileURL = fileURL.absoluteString
        savedFile.fileName = fileName
        savedFile.type = type
        savedFile.fileSizeKB = Int64(fileSize / 1024)
        savedFile.duration = duration
        saveContext()
    }

    // MARK: - Delete SavedFileEntity
    func deleteSavedFile(_ file: SavedFileEntity) {
        context.delete(file)
        saveContext()
    }
}

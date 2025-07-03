//
//  CoreDataManager.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import Foundation
import CoreData
import UIKit

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
    func addSavedFile(fileURL: URL, fileName: String, type: String, fileSize: UInt64, duration: String, image: UIImage? = nil, imageFileExtension: String? = nil) {
        let savedFile = SavedFileEntity(context: context)
        savedFile.id = UUID()
        savedFile.fileName = fileName
        savedFile.type = type
        savedFile.duration = duration
        savedFile.fileURL = fileURL.absoluteString
        savedFile.fileSizeKB = Int64(fileSize / 1024)
        
        if let ext = imageFileExtension {
            savedFile.imageFileExtension = ext.lowercased()
        } else {
            savedFile.imageFileExtension = "jpg"
        }
        
        savedFile.fileSizeKB = Int64(fileSize / 1024)
        
        if let image = image, let ext = imageFileExtension?.lowercased() {
            switch ext {
            case "jpg", "jpeg":
                savedFile.imageData = image.jpegData(compressionQuality: 1.0)
            case "png":
                savedFile.imageData = image.pngData()
            case "heic":
                savedFile.imageData = image.heicData(compressionQuality: 1.0)
            case "gif":
                GifCoder.exportToGIF(image: image) { url in
                    if let url = url, let data = try? Data(contentsOf: url) {
                        savedFile.imageData = data
                    } else {
                        savedFile.imageData = nil
                    }
                }
            case "webp":
                WebpCoder.exportToWebP(image: image) { url in
                    if let url = url, let data = try? Data(contentsOf: url) {
                        savedFile.imageData = data
                    } else {
                        savedFile.imageData = nil
                    }
                }
            default:
                savedFile.imageData = image.jpegData(compressionQuality: 1.0)
            }
        } else {
            savedFile.imageData = nil
        }
        
        saveContext()
    }

    // MARK: - Delete SavedFileEntity
    func deleteSavedFile(_ file: SavedFileEntity) {
        context.delete(file)
        saveContext()
    }
    
    func fetchFiles(ofType type: String) -> [SavedFileEntity] {
        let request: NSFetchRequest<SavedFileEntity> = SavedFileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "type ==[c] %@", type)
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
}

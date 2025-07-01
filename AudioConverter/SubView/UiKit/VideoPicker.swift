//
//  VideoPicker.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    @Binding var isPresented: Bool
    @Binding var errorMessage: String?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            parent.isPresented = false

            guard let provider = results.first?.itemProvider else { return }

            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let url = url {
                        self.copyToTempAndSet(url: url)
                    } else if let error = error {
                        DispatchQueue.main.async {
                            self.parent.errorMessage = "Error loading video file: \(error.localizedDescription)"
                        }
                    } else {
                        provider.loadDataRepresentation(forTypeIdentifier: UTType.movie.identifier) { data, error in
                            if let data = data {
                                let tempURL = FileManager.default.temporaryDirectory
                                    .appendingPathComponent(UUID().uuidString + ".mov")
                                do {
                                    try data.write(to: tempURL)
                                    DispatchQueue.main.async {
                                        self.parent.videoURL = tempURL
                                    }
                                } catch {
                                    DispatchQueue.main.async {
                                        self.parent.errorMessage = "Error writing video data to temp file: \(error.localizedDescription)"
                                    }
                                }
                            } else if let error = error {
                                DispatchQueue.main.async {
                                    self.parent.errorMessage = "Error loading video data: \(error.localizedDescription)"
                                }
                            }
                        }
                    }
                }
            }
        }
        
        func copyToTempAndSet(url: URL) {
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + url.lastPathComponent)
            
            do {
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    try FileManager.default.removeItem(at: tempURL)
                }
                try FileManager.default.copyItem(at: url, to: tempURL)
                DispatchQueue.main.async {
                    self.parent.videoURL = tempURL
                }
            } catch {
                print("Error copying video file: \(error)")
            }
        }
    }
}

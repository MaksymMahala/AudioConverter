//
//  AudioDocumentPicker.swift
//  AudioConverter
//
//  Created by Max on 02.07.2025.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

struct AudioDocumentPicker: UIViewControllerRepresentable {
    @Binding var audioURL: URL?
    @Binding var isPresented: Bool
    @Binding var errorMessage: String?
    
    var onStartLoading: () -> Void = {}
    var onPicked: () -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.audio, .mp3, .wav, .mpeg4Audio],
            asCopy: true
        )
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: AudioDocumentPicker
        
        init(_ parent: AudioDocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            controller.dismiss(animated: true)
            self.parent.isPresented = false
            
            guard let originalURL = urls.first else { return }
            
            DispatchQueue.main.async {
                self.parent.onStartLoading()
            }

            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + originalURL.lastPathComponent)

            do {
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    try FileManager.default.removeItem(at: tempURL)
                }
                try FileManager.default.copyItem(at: originalURL, to: tempURL)
                DispatchQueue.main.async {
                    self.parent.audioURL = tempURL
                    self.parent.onPicked()
                }
            } catch {
                DispatchQueue.main.async {
                    self.parent.errorMessage = "Error copying audio file: \(error.localizedDescription)"
                }
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true)
            self.parent.isPresented = false
        }
    }
}

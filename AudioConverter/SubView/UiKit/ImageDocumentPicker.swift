//
//  ImageDocumentPicker.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ImageDocumentPicker: UIViewControllerRepresentable {
    @Binding var imageURL: URL?
    @Binding var isPresented: Bool
    @Binding var errorMessage: String?

    var onStartLoading: () -> Void = {}
    var onPicked: () -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [.image, .jpeg, .png]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: ImageDocumentPicker

        init(_ parent: ImageDocumentPicker) {
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
                .appendingPathComponent(UUID().uuidString + "-" + originalURL.lastPathComponent)

            do {
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    try FileManager.default.removeItem(at: tempURL)
                }
                try FileManager.default.copyItem(at: originalURL, to: tempURL)
                DispatchQueue.main.async {
                    self.parent.imageURL = tempURL
                    self.parent.onPicked()
                }
            } catch {
                DispatchQueue.main.async {
                    self.parent.errorMessage = "Error copying selected image: \(error.localizedDescription)"
                }
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true)
            self.parent.isPresented = false
        }
    }
}

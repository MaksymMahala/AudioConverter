//
//  PhotoCapturePicker.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct PhotoCapturePicker: UIViewControllerRepresentable {
    @Binding var photoURL: URL?
    @Binding var isPresented: Bool
    @Binding var errorMessage: String?
    var onStartLoading: () -> Void = {}
    var onPicked: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoCapturePicker

        init(_ parent: PhotoCapturePicker) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.isPresented = false
            parent.onStartLoading()

            guard let image = info[.originalImage] as? UIImage else {
                parent.errorMessage = "Failed to capture photo."
                return
            }

            if let data = image.jpegData(compressionQuality: 1.0) {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("jpg")

                do {
                    try data.write(to: tempURL)
                    parent.photoURL = tempURL
                    parent.onPicked()
                } catch {
                    parent.errorMessage = "Failed to save photo to disk: \(error.localizedDescription)"
                }
            } else {
                parent.errorMessage = "Failed to process image data."
            }
        }
    }
}

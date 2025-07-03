//
//  ImagePicker.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var imageURL: URL?
    @Binding var isPresented: Bool
    @Binding var errorMessage: String?

    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var onStartLoading: () -> Void = {}
    var onPicked: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.isPresented = false
            parent.onStartLoading()

            guard let image = info[.originalImage] as? UIImage else {
                parent.errorMessage = "Failed to select image."
                return
            }

            parent.selectedImage = image

            if let data = image.jpegData(compressionQuality: 1.0) {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("jpg")

                do {
                    try data.write(to: tempURL)
                    parent.imageURL = tempURL
                    parent.onPicked()
                } catch {
                    parent.errorMessage = "Failed to save image to disk: \(error.localizedDescription)"
                }
            } else {
                parent.errorMessage = "Failed to process image data."
            }
        }
    }
}

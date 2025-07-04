//
//  ImageConversionSheet.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import SwiftUI

struct ImageConversionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isLoadingImage: Bool
    @ObservedObject var viewModel: ImageToolsViewModel
    @StateObject private var driveViewModel = GoogleDriveViewModel()
    @StateObject private var signInViewModel = GoogleSignInViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                content
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    switch viewModel.imageAction {
                    case .convert:
                        Text("Image conversion")
                            .font(Font.custom(size: 18, weight: .bold))
                            .foregroundStyle(Color.darkBlueD90)
                    case .edit:
                        Text("Edit Image")
                            .font(Font.custom(size: 18, weight: .bold))
                            .foregroundStyle(Color.darkBlueD90)
                    case .gif:
                        Text("Creating GIF files")
                            .font(Font.custom(size: 18, weight: .bold))
                            .foregroundStyle(Color.darkBlueD90)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.black)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isDocumentPickerPresented) {
            ImageDocumentPicker(
                imageURL: $viewModel.imageURL,
                isPresented: $viewModel.isDocumentPickerPresented,
                errorMessage: $viewModel.errorMessage,
                onStartLoading: {
                    dismiss()
                    isLoadingImage = true
                },
                onPicked: {
                    switch viewModel.imageAction {
                    case .convert:
                        viewModel.isEditorPresented = true
                    case .edit:
                        viewModel.openEditImageEditor = true
                    case .gif:
                        viewModel.openGIFImageEditor = true
                    }
                }
            )
        }
        .sheet(isPresented: $viewModel.isImagePickerPresented) {
            ImagePicker(
                selectedImage: $viewModel.selectedImage,
                imageURL: $viewModel.imageURL,
                isPresented: $viewModel.isImagePickerPresented,
                errorMessage: $viewModel.errorMessage,
                onStartLoading: {
                    dismiss()
                    isLoadingImage = true
                },
                onPicked: {
                    switch viewModel.imageAction {
                    case .convert:
                        viewModel.isEditorPresented = true
                    case .edit:
                        viewModel.openEditImageEditor = true
                    case .gif:
                        viewModel.openGIFImageEditor = true
                    }
                }
            )
        }
        .sheet(isPresented: $viewModel.isDrivePickerPresented) {
            DriveFilePickerView(viewModel: driveViewModel) { selectedURL in
                viewModel.imageURL = selectedURL
            }
        }
        .sheet(isPresented: $viewModel.isCameraPresented) {
            PhotoCapturePicker(
                photoURL: $viewModel.imageURL,
                isPresented: $viewModel.isCameraPresented,
                errorMessage: $viewModel.errorMessage,
                onStartLoading: {
                    isLoadingImage = true
                },
                onPicked: {
                    switch viewModel.imageAction {
                    case .convert:
                        viewModel.isEditorPresented = true
                    case .edit:
                        viewModel.openEditImageEditor = true
                    case .gif:
                        viewModel.openEditImageEditor = true
                    }
                }
            )
        }
        .alert("Unable to Upload File", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { newValue in
                if !newValue { viewModel.errorMessage = nil }
            }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var content: some View {
        VStack(spacing: 10) {
            Group {
                ButtonRow(title: "Google Drive", image: "iconoir_google-drive") {
                    if let token = signInViewModel.accessToken {
                        driveViewModel.accessToken = token
                        viewModel.isDrivePickerPresented = true
                    } else {
                        signInViewModel.signIn()
                    }
                }
                ButtonRow(title: "Import file", image: "iconoir_folder") {
                    viewModel.isDocumentPickerPresented = true
                }
                ButtonRow(title: "Photo library", image: "iconoir_media-image_gray") {
                    viewModel.isImagePickerPresented = true
                }
                ButtonRow(title: "Take a photo", image: "iconoir_camera") {
                    viewModel.isCameraPresented = true
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }
}

#Preview {
    ImageConversionSheet(isLoadingImage: .constant(false), viewModel: ImageToolsViewModel())
}

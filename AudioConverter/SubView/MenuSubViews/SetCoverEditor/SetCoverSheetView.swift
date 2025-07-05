//
//  SetCoverSheetView.swift
//  AudioConverter
//
//  Created by Max on 05.07.2025.
//

import SwiftUI

struct SetCoverSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel = ImageToolsViewModel()
    @StateObject private var driveViewModel = GoogleDriveViewModel()
    @StateObject private var signInViewModel = GoogleSignInViewModel()
    @Binding var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            ScrollView {
                header
                
                content
            }
        }
        .sheet(isPresented: $viewModel.isDocumentPickerPresented) {
            ImageDocumentPicker(
                imageURL: $viewModel.imageURL,
                isPresented: $viewModel.isDocumentPickerPresented,
                errorMessage: $viewModel.errorMessage,
                onStartLoading: {
                },
                onPicked: {
                    if let imageURL = viewModel.imageURL,
                       let data = try? Data(contentsOf: imageURL),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        dismiss()
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
                },
                onPicked: {
                    if let image = viewModel.selectedImage {
                        selectedImage = image
                        dismiss()
                    }
                }
            )
        }
        .sheet(isPresented: $viewModel.isDrivePickerPresented) {
            DriveFilePickerView(viewModel: driveViewModel) { selectedURL in
                viewModel.imageURL = selectedURL
                if let data = try? Data(contentsOf: selectedURL),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $viewModel.isCameraPresented) {
            PhotoCapturePicker(
                photoURL: $viewModel.imageURL,
                isPresented: $viewModel.isCameraPresented,
                errorMessage: $viewModel.errorMessage,
                onStartLoading: {
                },
                onPicked: {
                    if let imageURL = viewModel.imageURL,
                        let data = try? Data(contentsOf: imageURL),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        dismiss()
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
    
    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.black)
            }
            
            Spacer()
            
            Text("Set cover")
                .font(Font.custom(size: 18, weight: .bold))
                .foregroundStyle(Color.darkBlueD90)
            
            Spacer()
            
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.black)
            }
        }
        .padding()
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
        .padding(.top, 30)
    }
}

#Preview {
    SetCoverSheetView(selectedImage: .constant(UIImage(named: "iconoir_camera")))
}

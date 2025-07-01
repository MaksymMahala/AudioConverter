//
//  AudioConversionSheet.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct AudioConversionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: VideoToolsViewModel
    @StateObject private var driveViewModel = GoogleDriveViewModel()
    @StateObject private var signInViewModel = GoogleSignInViewModel()
    
    @State private var isVideoPickerPresented = false
    @State private var errorMessage: String?

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
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Audio conversion")
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isDocumentPickerPresented) {
            DocumentPicker(videoURL: $viewModel.videoURL)
        }
        .fullScreenCover(isPresented: $viewModel.isCameraPresented) {
            CameraCaptureView(videoURL: $viewModel.videoURL)
        }
        .sheet(isPresented: $viewModel.isDrivePickerPresented) {
            DriveFilePickerView(viewModel: driveViewModel) { selectedURL in
                viewModel.videoURL = selectedURL
            }
        }
        .sheet(isPresented: $isVideoPickerPresented) {
            VideoPicker(videoURL: $viewModel.videoURL, isPresented: $isVideoPickerPresented, errorMessage: $errorMessage)
                .onDisappear {
                    viewModel.isLoadingVideo = true
                    viewModel.isEditorPresented = true
                }
        }
        .alert("Uploading troubles", isPresented: Binding<Bool>(
               get: { errorMessage != nil },
               set: { newValue in
                   if !newValue { errorMessage = nil }
               }
           )) {
               Button("OK", role: .cancel) {}
           } message: {
               Text(errorMessage ?? "")
           }
    }

    private var content: some View {
        VStack(spacing: 20) {
            linkImportSection
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal)

            Group {
                ButtonRow(title: "Google Drive", systemImage: "triangle") {
                    if let token = signInViewModel.accessToken {
                        driveViewModel.accessToken = token
                        viewModel.isDrivePickerPresented = true
                    } else {
                        signInViewModel.signIn()
                    }
                }
                ButtonRow(title: "Import file", systemImage: "folder") {
                    viewModel.isDocumentPickerPresented = true
                }
                ButtonRow(title: "Photo library", systemImage: "photo.on.rectangle") {
                    isVideoPickerPresented = true  // відкриваємо кастомний відео пікер
                }
                ButtonRow(title: "Take a photo", systemImage: "camera") {
                    viewModel.isCameraPresented = true
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    private var linkImportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import from the link")
                .font(.headline)

            TextField("Add link", text: $viewModel.inputLink)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .keyboardType(.URL)

            Button(action: {
                viewModel.validateLink()
            }) {
                Text("Add")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
            }
        }
    }
}

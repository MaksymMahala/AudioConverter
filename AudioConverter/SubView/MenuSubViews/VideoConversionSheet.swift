//
//  VideoConversionSheet.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct VideoConversionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isLoadingVideo: Bool
    @ObservedObject var viewModel: VideoToolsViewModel
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
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Video conversion")
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
        .sheet(isPresented: $viewModel.isVideoPickerPresented) {
            VideoPicker(
                videoURL: $viewModel.videoURL,
                isPresented: $viewModel.isVideoPickerPresented,
                errorMessage: $viewModel.errorMessage,
                onStartLoading: {
                    isLoadingVideo = true
                },
                onPicked: {
                    viewModel.isEditorPresented = true
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
                    viewModel.isVideoPickerPresented = true
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

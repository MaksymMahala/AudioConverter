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
                            .foregroundStyle(Color.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    switch viewModel.videoAction {
                    case .convert:
                        Text("Video conversion")
                            .font(Font.custom(size: 18, weight: .bold))
                            .foregroundStyle(Color.darkBlueD90)
                    case .videoToAudio:
                        Text("Video to audio")
                            .font(Font.custom(size: 18, weight: .bold))
                            .foregroundStyle(Color.darkBlueD90)
                    case .trim:
                        Text("Trim video")
                            .font(Font.custom(size: 18, weight: .bold))
                            .foregroundStyle(Color.darkBlueD90)
                    case .cut:
                        Text("Cut video")
                            .font(Font.custom(size: 18, weight: .bold))
                            .foregroundStyle(Color.darkBlueD90)
                    case .compress:
                        Text("Compress video")
                            .font(Font.custom(size: 18, weight: .bold))
                            .foregroundStyle(Color.darkBlueD90)
                    case .delete:
                        Text("Delete a video")
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
            VideoDocumentPicker(
                videoURL: $viewModel.videoURL,
                isPresented: $viewModel.isDocumentPickerPresented,
                errorMessage: $viewModel.errorMessage,
                onStartLoading: {
                    dismiss()
                    isLoadingVideo = true
                },
                onPicked: {
                    switch viewModel.videoAction {
                    case .convert:
                        viewModel.isEditorPresented = true
                    case .videoToAudio:
                        viewModel.isEditorPresented = true
                    case .trim:
                        viewModel.isTrimEditorPresented = true
                    case .cut:
                        viewModel.isCutEditorPresented = true
                    case .compress:
                        viewModel.isCompressEditorPresented = true
                    case .delete:
                        viewModel.isDeleteEditorPresented = true
                    }
                }
            )
        }
        .sheet(isPresented: $viewModel.isCameraPresented) {
            CameraCaptureView(
                videoURL: $viewModel.videoURL,
                isPresented: $viewModel.isCameraPresented,
                errorMessage: $viewModel.errorMessage,
                onStartLoading: {
                    isLoadingVideo = true
                },
                onPicked: {
                    switch viewModel.videoAction {
                    case .convert:
                        viewModel.isEditorPresented = true
                    case .videoToAudio:
                        viewModel.isEditorPresented = true
                    case .trim:
                        viewModel.isTrimEditorPresented = true
                    case .cut:
                        viewModel.isCutEditorPresented = true
                    case .compress:
                        viewModel.isCompressEditorPresented = true
                    case .delete:
                        viewModel.isDeleteEditorPresented = true
                    }
                }
            )
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
                    switch viewModel.videoAction {
                    case .convert:
                        viewModel.isEditorPresented = true
                    case .videoToAudio:
                        viewModel.isEditorPresented = true
                    case .trim:
                        viewModel.isTrimEditorPresented = true
                    case .cut:
                        viewModel.isCutEditorPresented = true
                    case .compress:
                        viewModel.isCompressEditorPresented = true
                    case .delete:
                        viewModel.isDeleteEditorPresented = true
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
            linkImportSection
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal)

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
                    viewModel.isVideoPickerPresented = true
                }
                ButtonRow(title: "Take a photo", image: "iconoir_camera") {
                    viewModel.isCameraPresented = true
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    private var linkImportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(.iconoirLink)
                Text("Import from the link")
            }
            .font(Font.custom(size: 16, weight: .bold))
            .foregroundStyle(Color.black)

            TextField("Add link", text: $viewModel.inputLink)
                .padding()
                .font(Font.custom(size: 16, weight: .regular))
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .keyboardType(.URL)

            Button(action: {
                viewModel.validateLink(isLoadingVideo: $isLoadingVideo) {
                    dismiss()
                }
            }) {
                Text("Add")
                    .font(Font.custom(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.darkPurple)
                    .cornerRadius(20)
            }
        }
    }
}

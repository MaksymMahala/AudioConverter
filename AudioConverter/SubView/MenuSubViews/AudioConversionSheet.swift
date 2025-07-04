//
//  AudioConversionSheet.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import SwiftUI

struct AudioConversionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AudioConversionViewModel
    @Binding var isLoadingAudio: Bool
    
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
                    switch viewModel.audioAction {
                    case .convert:
                        Text("Audio conversion")
                            .font(Font.custom(size: 18, weight: .bold))
                            .foregroundStyle(Color.darkBlueD90)
                    case .trim:
                        Text("Trim audio")
                            .font(Font.custom(size: 18, weight: .bold))
                            .foregroundStyle(Color.darkBlueD90)
                    case .createMelody:
                        Text("Create a melody")
                            .font(Font.custom(size: 18, weight: .bold))
                            .foregroundStyle(Color.darkBlueD90)
                    case .edit:
                        Text("Edit Audio")
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
        .sheet(isPresented: $viewModel.isDrivePickerPresented) {
            DriveFilePickerView(viewModel: driveViewModel) { selectedURL in
                viewModel.audioURL = selectedURL
            }
        }
        .sheet(isPresented: $viewModel.isDocumentPickerPresented) {
            AudioDocumentPicker(
                audioURL: $viewModel.audioURL,
                isPresented: $viewModel.isDocumentPickerPresented,
                errorMessage: $viewModel.errorMessage,
                onStartLoading: {
                    dismiss()
                    isLoadingAudio = true
                },
                onPicked: {
                    switch viewModel.audioAction {
                    case .convert:
                        viewModel.isEditorPresented = true
                    case .trim:
                        viewModel.isEditorPresented = true
                    case .createMelody:
                        viewModel.isEditorPresented = true
                    case .edit:
                        viewModel.isEditorPresented = true
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
            }
            .padding(.horizontal)

            Spacer()
        }
    }
}

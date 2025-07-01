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
                    Text("Audio conversion")
                        .font(Font.custom(size: 18, weight: .bold))
                        .foregroundStyle(Color.darkBlueD90)
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
            DocumentPicker(videoURL: $viewModel.audioURL)
        }
        .sheet(isPresented: $viewModel.isDrivePickerPresented) {
            DriveFilePickerView(viewModel: driveViewModel) { selectedURL in
                viewModel.audioURL = selectedURL
            }
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

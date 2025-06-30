//
//  AudioConversionSheet.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI
import UniformTypeIdentifiers
import PhotosUI
import AVFoundation

struct AudioConversionSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var videoURL: URL?
    @State private var inputLink: String = ""
    @State private var isDocumentPickerPresented = false
    @State private var isPhotoPickerPresented = false
    @State private var isCameraPresented = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isLinkValid = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Import from the link")
                            .font(Font.custom(size: 16, weight: .bold))
                            .foregroundStyle(Color.black)
                        
                        TextField("Add link", text: $inputLink)
                            .padding(12)
                            .background(Color.gray20)
                            .font(Font.custom(size: 16, weight: .medium))
                            .cornerRadius(8)
                            .keyboardType(.URL)
                        
                        Button(action: {
                            validateLink()
                        }) {
                            Text("Add")
                                .font(Font.custom(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.darkPurple)
                                .cornerRadius(30)
                        }
                    }
                    .padding()
                    .padding(.vertical)
                    .background(Color.grayF7F8FA)
                    .cornerRadius(20)
                    .padding()
                    
                    Group {
                        ButtonRow(title: "Google Drive", systemImage: "triangle") {
                            print("Google Drive tapped")
                        }
                        
                        ButtonRow(title: "Import file", systemImage: "folder") {
                            isDocumentPickerPresented = true
                        }
                        
                        ButtonRow(title: "Photo library", systemImage: "photo.on.rectangle") {
                            isPhotoPickerPresented = true
                        }
                        
                        ButtonRow(title: "Take a photo", systemImage: "camera") {
                            isCameraPresented = true
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                        } label: {
                            Image(.iconoirXmark)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Button {
                        } label: {
                            Text("Audio conversion")
                                .font(Font.custom(size: 18, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                        } label: {
                            Image(.iconoirXmark)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isDocumentPickerPresented) {
            DocumentPicker(videoURL: $videoURL)
        }
        .photosPicker(isPresented: $isPhotoPickerPresented, selection: $selectedItem, matching: .videos)
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraCaptureView(videoURL: $videoURL)
        }
        .onChange(of: selectedItem) { newItem, _ in
            Task {
                if let item = newItem {
                    if let url = try? await item.loadTransferable(type: URL.self) {
                        self.videoURL = url
                    }
                }
            }
        }
    }

    private func validateLink() {
        if let url = URL(string: inputLink), UIApplication.shared.canOpenURL(url) {
            videoURL = url
            isLinkValid = true
        } else {
            isLinkValid = false
        }
    }
}

#Preview {
    AudioConversionSheet()
}

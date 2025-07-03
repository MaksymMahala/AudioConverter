//
//  ImageEditorView.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import SwiftUI

struct ImageEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerViewModel = PlayerViewModel()
    let imageURL: URL?
    
    @Binding var selectedImage: UIImage?
    @Binding var isLoading: Bool
    @Binding var isEditorPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    imageSection
                    Divider()
                        .padding(.top, 20)
                    formatScroll
                    convertButton
                    
                    Spacer()
                }
            }
            .onAppear {
                playerViewModel.fileType = .image
                isLoading = false
            }
        }
    }
    
    // MARK: UI Components
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.backward")
                    .foregroundStyle(Color.black)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var imageSection: some View {
        VStack(alignment: .leading) {
            Text(imageURL?.lastPathComponent ?? "Image")
                .foregroundStyle(Color.black)
                .font(Font.custom(size: 16, weight: .bold))
                .padding(.top, 10)
                .padding(.horizontal)
            
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 361, height: 398)
                    .padding(.top, 6)
            }
        }
    }
    
    private var convertButton: some View {
        Button {
            if let imageURL = imageURL, let selectedImage = selectedImage {
                playerViewModel.convertToImageFormat(inputURL: imageURL) { convertedURL in
                    if let convertedURL = convertedURL {
                        print("Image converted to \(playerViewModel.selectedFormat): \(convertedURL)")
                        playerViewModel.saveConvertedImageToDB(url: convertedURL, fileName: convertedURL.lastPathComponent, type: "Image", selectedImage: selectedImage)
                        isEditorPresented = false
                        dismiss()
                    } else {
                        print("Image conversion failed.")
                    }
                }
            }
        } label: {
            Text("Convert")
                .padding(13)
                .frame(maxWidth: .infinity)
                .background(Color.darkPurple)
                .foregroundStyle(Color.white)
                .cornerRadius(30)
                .padding(.horizontal)
                .padding(.top, 10)
        }
    }
    
    private var formatScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(playerViewModel.availableFormats, id: \.self) { format in
                    Button {
                        playerViewModel.selectedFormat = format
                    } label: {
                        Text(format)
                            .font(Font.custom(size: 16, weight: .medium))
                            .foregroundColor(.darkBlueD90)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .frame(height: 78)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(playerViewModel.selectedFormat == format ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    func controlButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .resizable()
                .frame(width: 15, height: 15)
                .foregroundColor(.black)
                .padding()
                .background(Color.gray20.opacity(0.5))
                .cornerRadius(30)
        }
    }
    
    func tabButton(title: String) -> some View {
        Button(action: { playerViewModel.selectedTab = title }) {
            Text(title)
                .font(Font.custom(size: 16, weight: .regular))
                .foregroundColor(playerViewModel.selectedTab == title ? .darkBlueD90 : .gray50)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .background(playerViewModel.selectedTab == title ? Color.secondary0110 : Color.clear)
                .clipShape(Capsule())
        }
    }
}

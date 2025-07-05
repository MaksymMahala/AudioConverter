//
//  EditImageEditorView.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import SwiftUI

struct EditImageEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerViewModel = PlayerViewModel()
    let imageURL: URL?
    
    @Binding var selectedImage: UIImage?
    @Binding var isLoading: Bool
    
    @State private var selectedControl: String? = nil
    @State private var originalImage: UIImage?
    @State private var isMirrored = false
    @State private var isFlipped = false
    @State private var cropRect: CGRect? = nil
    @State private var editedImage: UIImage?

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    
                    ScrollView(showsIndicators: false) {
                        imageSection
                    }
                    
                    controlButtons
                    
                    Spacer()
                }
            }
            .padding(.bottom)
            .onAppear {
                playerViewModel.fileType = .image
                isLoading = false
                
                if originalImage == nil {
                    originalImage = selectedImage
                }
            }
            .onChange(of: selectedImage) { newImage, _ in
                if originalImage == nil {
                    originalImage = newImage
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(Color.black)
                }
                
                Button("Reset settings") {
                    resetImageEdits()
                }
                .foregroundStyle(Color.black)
                .font(Font.custom(size: 16, weight: .bold))
                
                Text(imageURL?.lastPathComponent ?? "Image")
                    .foregroundStyle(Color.black)
                    .font(Font.custom(size: 16, weight: .bold))
                    .padding(.top, 10)
                    .padding(.horizontal)
            }
            Spacer()
            
            Button("Done") {
                if let imageURL = imageURL {
                    playerViewModel.saveEditedImageToDB(fileName: imageURL.absoluteString, type: "Image", selectedImage: selectedImage)
                    if let controller = ShareHelper.getRootController() {
                        ShareManager.shared.shareFiles([imageURL], from: controller)
                    }
                    dismiss()
                }
            }
            .foregroundStyle(Color.black)
            .font(Font.custom(size: 16, weight: .bold))
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var imageSection: some View {
        if let selectedImage = selectedImage {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFit()
                .frame(width: 361, height: 398)
                .padding(.top, 6)
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 20) {
            Button(action: {
                selectedControl = "Mirror"
                mirrorImage()
            }) {
                VStack {
                    Image(.iconoirFlip)
                        .padding()
                        .frame(width: 78, height: 78)
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(selectedControl == "Mirror" ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                        )
                        .cornerRadius(50)
                    Text("Mirror")
                        .foregroundColor(.darkBlueD90)
                        .font(Font.custom(size: 16, weight: .medium))
                        .padding(.top, 5)
                }
            }

            Button(action: {
                selectedControl = "Flip"
                flipImage()
            }) {
                VStack {
                    Image(.iconoirTurn)
                        .padding()
                        .frame(width: 78, height: 78)
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(selectedControl == "Flip" ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                        )
                        .cornerRadius(50)
                    Text("Flip")
                        .foregroundColor(.darkBlueD90)
                        .font(Font.custom(size: 16, weight: .medium))
                        .padding(.top, 5)
                }
            }

            Button(action: {
                selectedControl = "Crop"
                
                cropImage()
            }) {
                VStack {
                    Image(.iconoirCrop)
                        .padding()
                        .frame(width: 78, height: 78)
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(selectedControl == "Crop" ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                        )
                        .cornerRadius(50)
                    Text("Crop")
                        .foregroundColor(.darkBlueD90)
                        .font(Font.custom(size: 16, weight: .medium))
                        .padding(.top, 5)
                }
            }
        }
        .padding(.vertical, 15)
    }
    
    private func mirrorImage() {
        guard let input = selectedImage else { return }
        let mirrored = UIImage(cgImage: input.cgImage!, scale: input.scale, orientation: .upMirrored)
        selectedImage = mirrored
        isMirrored = true
    }

    private func flipImage() {
        guard let input = selectedImage else { return }
        let flipped = UIImage(cgImage: input.cgImage!, scale: input.scale, orientation: .leftMirrored)
        selectedImage = flipped
        isFlipped = true
    }

    private func cropImage() {
        guard let input = selectedImage else { return }
        selectedImage = cropToCenterSquare(image: input)
        cropRect = CGRect(x: 0, y: 0, width: selectedImage?.size.width ?? 0, height: selectedImage?.size.height ?? 0)
    }

    func resetImageEdits() {
        isMirrored = false
        isFlipped = false
        cropRect = nil
        selectedImage = originalImage
    }
    
    private func cropToCenterSquare(image: UIImage) -> UIImage {
        let cgImage = image.cgImage!
        let length = min(cgImage.width, cgImage.height)
        let x = (cgImage.width - length) / 2
        let y = (cgImage.height - length) / 2
        let cropRect = CGRect(x: x, y: y, width: length, height: length)
        guard let croppedCgImage = cgImage.cropping(to: cropRect) else { return image }
        return UIImage(cgImage: croppedCgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

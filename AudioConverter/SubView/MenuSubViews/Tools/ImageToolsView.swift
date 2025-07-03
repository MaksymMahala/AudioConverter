//
//  ImageToolsView.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct ImageToolsView: View {
    @StateObject private var viewModel = ImageToolsViewModel()
    @Binding var isLoadingImage: Bool

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label {
                Text("Image")
                    .foregroundStyle(Color.darkBlueD90)
                    .font(Font.custom(size: 18, weight: .bold))
            } icon: {
                Image(.iconoirMedia)
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.tools) { tool in
                    Button {
                        switch tool.title {
                        case "Convert images":
                            withAnimation {
                                viewModel.openImageView = true
                                viewModel.imageAction = .convert
                            }
                        case "Creating GIF files":
                            print("Creating GIF files tapped")
                        default:
                            withAnimation {
                                viewModel.imageAction = .convert
                                viewModel.openImageView = true
                            }
                        }
                    } label: {
                        ToolCard(tool: tool)
                    }
                }
            }
            .padding(.horizontal)

            Button {
                withAnimation {
                    viewModel.openImageView = true
                    viewModel.imageAction = .edit
                }
            } label: {
                WideToolCard(tool: viewModel.bottomTool)
            }
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $viewModel.isEditorPresented) {
            ImageEditorView(imageURL: viewModel.imageURL, selectedImage: $viewModel.selectedImage, isLoading: $isLoadingImage, isEditorPresented: $viewModel.isEditorPresented)
        }
        .fullScreenCover(isPresented: $viewModel.openEditImageEditor) {
            EditImageEditorView(imageURL: viewModel.imageURL, selectedImage: $viewModel.selectedImage, isLoading: $isLoadingImage)
        }
        .sheet(isPresented: $viewModel.openImageView) {
            ImageConversionSheet(isLoadingImage: $isLoadingImage, viewModel: viewModel)
        }
    }
}

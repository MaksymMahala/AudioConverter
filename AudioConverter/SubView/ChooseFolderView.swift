//
//  ChooseFolderView.swift
//  AudioConverter
//
//  Created by Max on 04.07.2025.
//

import SwiftUI

struct ChooseFolderView: View {
    @ObservedObject var worksViewModel: WorksViewModel
    var body: some View {
        VStack {
            Text("Choose Folder")
                .foregroundStyle(Color.black)
                .font(Font.custom(size: 16, weight: .bold))
                .padding(.top)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(worksViewModel.playlists, id: \.self) { folder in
                        Button(action: {
                            if let file = worksViewModel.selectedFile {
                                worksViewModel.addFile(file, toPlaylist: folder)
                                worksViewModel.showFolderPickerSheet = false
                            }
                        }) {
                            HStack {
                                Image(.iconoirFolder)
                                Text(folder)
                                    .font(Font.custom(size: 14, weight: .medium))
                                    .foregroundStyle(Color.black)
                                Spacer()
                            }
                            .padding()
                            .background(Color(.gray20).opacity(0.5))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            
            Button("Cancel") {
                worksViewModel.showFolderPickerSheet = false
            }
            .foregroundStyle(Color.black)
            .padding()
            .font(Font.custom(size: 16, weight: .bold))
            .frame(maxWidth: .infinity)
            .background(Color.primary130)
            .cornerRadius(15)
            .padding(.horizontal)
        }
        .presentationDetents([.medium])
    }
}

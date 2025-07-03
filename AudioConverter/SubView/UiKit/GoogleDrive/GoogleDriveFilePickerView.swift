//
//  GoogleDriveFilePickerView.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct DriveFilePickerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GoogleDriveViewModel
    var onSelect: (URL) -> Void

    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else {
                    ForEach(viewModel.files) { file in
                        Button(action: {
                            if let link = file.webContentLink, let url = URL(string: link) {
                                onSelect(url)
                                dismiss()
                            }
                        }) {
                            Text(file.name)
                        }
                    }
                }
            }
            .navigationTitle("Google Drive")
            .onAppear {
                viewModel.fetchFiles()
            }
        }
    }
}

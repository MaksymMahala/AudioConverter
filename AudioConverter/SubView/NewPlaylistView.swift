//
//  NewPlaylistView..swift
//  AudioConverter
//
//  Created by Max on 04.07.2025.
//

import SwiftUI

struct NewPlaylistView: View {
    @ObservedObject var worksViewModel: WorksViewModel

    var body: some View {
        VStack {
            Text("New Playlist")
                .foregroundStyle(Color.black)
                .font(Font.custom(size: 16, weight: .bold))
            
            Spacer()
            
            TextField("Playlist name", text: $worksViewModel.newPlaylistName)
                .textFieldStyle(.roundedBorder)
                .foregroundStyle(Color.gray50)
                .font(Font.custom(size: 14, weight: .medium))
                .padding()
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    worksViewModel.showCreatePlaylistView = false
                }
                .foregroundStyle(Color.black)
                .padding()
                .font(Font.custom(size: 16, weight: .bold))
                .frame(maxWidth: .infinity)
                .background(Color.primary130)
                .cornerRadius(15)
                Spacer()
                Button("Create") {
                    worksViewModel.createNewPlaylist()
                    worksViewModel.loadPlaylists()
                    worksViewModel.showCreatePlaylistView = false
                }
                .foregroundStyle(Color.white)
                .padding()
                .font(Font.custom(size: 16, weight: .bold))
                .frame(maxWidth: .infinity)
                .background(Color.darkBlueD90)
                .cornerRadius(15)
            }
            .padding()
        }
        .padding()
        .presentationDetents([.fraction(0.4)])
    }
}

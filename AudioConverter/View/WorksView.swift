//
//  WorksView.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import SwiftUI

struct WorksView: View {
    @StateObject private var worksViewModel = WorksViewModel()
    var body: some View {
        NavigationView {
            VStack {
                Text("Works")
                    .foregroundStyle(Color.black)
                    .font(Font.custom(size: 20, weight: .bold))
                
                List {
                    ForEach(worksViewModel.savedFiles, id: \.id) { file in
                        HStack(spacing: 16) {
                            Image(systemName: "waveform")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.purple)
                            VStack(alignment: .leading) {
                                Text(file.fileName ?? "Unknown")
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(file.type?.capitalized ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
}

#Preview {
    WorksView()
}

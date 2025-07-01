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
                
                ScrollView(showsIndicators: false) {
                    tabs
                    
                    createTab
                    
                    folders
                    
                    listSavedFiles
                }
            }
        }
    }
    
    private var tabs: some View {
        HStack {
            tabButton(title: "Video")
            tabButton(title: "Audio")
            tabButton(title: "Image")
        }
        .frame(height: 30)
        .background(Color(.gray20).opacity(0.5))
        .clipShape(Capsule())
        .padding()
    }
    
    private func tabButton(title: String) -> some View {
        Button(action: { worksViewModel.selectedTab = title }) {
            Text(title)
                .font(Font.custom(size: 16, weight: .regular))
                .foregroundColor(worksViewModel.selectedTab == title ? .darkBlueD90 : .gray50)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .background(worksViewModel.selectedTab == title ? Color.secondary0110 : Color.clear)
                .clipShape(Capsule())
        }
    }
    
    private var createTab: some View {
        Button {
            
        } label: {
            HStack {
                Image(.iconoirPlusCircleSolid)
                Text("Create Playlist")
                    .foregroundStyle(Color.darkBlueD90)
            }
        }
        .font(Font.custom(size: 16, weight: .regular))
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 78)
        .background(Color(.gray20).opacity(0.5))
        .cornerRadius(20)
        .padding()
    }
    
    private var folders: some View {
        VStack(alignment: .leading) {
            Text("Folders")
                .foregroundStyle(Color.darkBlueD90)
                .font(Font.custom(size: 18, weight: .bold))
                .padding(.leading, 5)
                .padding(.vertical)
            
            folder(image: .iconoirHeartSolid, backColor: Color.primary130, textTitle: "My Favorites", objCount: 10, action: {
                
            })
            
            folder(image: .iconoirFaceId, backColor: Color.gray20, textTitle: "Hidden folder", objCount: 5, action: {
                
            })
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.gray20).opacity(0.5))
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    private func folder(image: ImageResource, backColor: Color, textTitle: String, objCount: Int, action: @escaping () -> ()) -> some View {
        Button(action: action) {
            HStack {
                Image(image)
                    .padding()
                    .frame(width: 78, height: 78)
                    .background(backColor)
                    .cornerRadius(20)
                    .padding(5)
                
                VStack(alignment: .leading) {
                    Text(textTitle)
                        .foregroundStyle(Color.black)
                        .font(Font.custom(size: 16, weight: .medium))
                    
                    Text("\(objCount) objects")
                        .foregroundStyle(Color.gray50)
                        .font(Font.custom(size: 14, weight: .regular))
                }
                .padding(.leading, 6)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.black)
                    .padding(.trailing, 5)
            }
        }
    }
    
    private var listSavedFiles: some View {
        VStack(alignment: .leading) {
            Text("Play all")
                .foregroundStyle(Color.darkBlueD90)
                .font(Font.custom(size: 18, weight: .bold))
                .padding(.leading, 5)
                .padding(.vertical)
            
            ForEach(worksViewModel.savedFiles, id: \.id) { file in
                HStack {
                    Image(systemName: "waveform")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.darkPurple)
                        .padding()
                        .frame(width: 78, height: 78)
                        .background(Color.gray20)
                        .cornerRadius(20)
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text(file.fileName ?? "Unknown")
                            .font(Font.custom(size: 16, weight: .bold))
                            .foregroundStyle(Color.black)
                            .lineLimit(1)
                        Text(file.type?.capitalized ?? "")
                            .font(Font.custom(size: 14, weight: .regular))
                            .foregroundStyle(Color.gray40)
                    }
                    .padding(.leading, 6)
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image("iconoir_more-horiz")
                    }
                    .padding(.trailing, 5)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.gray20).opacity(0.5))
        .cornerRadius(20)
        .padding()
    }
}

#Preview {
    WorksView()
}

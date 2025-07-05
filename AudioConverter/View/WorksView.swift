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
                HeaderWithPay(title: "Works") {
                    worksViewModel.showSubsView = true
                }
                
                ScrollView(showsIndicators: false) {
                    tabs
                    
                    createTab
                    
                    folders
                    
                    if !worksViewModel.savedFiles.isEmpty {
                        listSavedFiles
                    }
                }
            }
            .fullScreenCover(isPresented: $worksViewModel.showSubsView) {
                SubsView()
            }
            .blur(radius: worksViewModel.alertType == .deleteFile ? 5 : 0)
            .blur(radius: worksViewModel.alertType == .newPlaylist ? 5 : 0)
            .sheet(isPresented: $worksViewModel.showFolderPickerSheet) {
                ChooseFolderView(worksViewModel: worksViewModel)
            }
            .sheet(isPresented: $worksViewModel.showCreatePlaylistView) {
                NewPlaylistView(worksViewModel: worksViewModel)
            }
            .alert(item: $worksViewModel.alertType) { alertType in
                switch alertType {
                case .deleteFile:
                    return Alert(
                        title: Text("Delete File"),
                        message: Text("Are you sure you want to delete this file? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            if let selectedFile = worksViewModel.selectedFile {
                                worksViewModel.deleteFile(file: selectedFile)
                            }
                            worksViewModel.loadFiles()
                        },
                        secondaryButton: .cancel()
                    )
                case .newPlaylist:
                    return Alert(
                        title: Text("New Playlist"),
                        message: Text("This feature requires a name input, shown in a sheet."),
                        primaryButton: .default(Text("Create")) {
                            worksViewModel.alertType = nil
                            worksViewModel.showCreatePlaylistView = true
                        },
                        secondaryButton: .cancel()
                    )
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
            withAnimation {
                worksViewModel.alertType = .newPlaylist
            }
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
            
            ForEach(worksViewModel.playlists, id: \.self) { name in
                let count = worksViewModel.getFileIDs(forPlaylist: name).count
                let (icon, color) = worksViewModel.iconAndColor(for: name)
                
                folder(image: icon, backColor: color, textTitle: name, objCount: count, action: {
                })
            }
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
                    if worksViewModel.selectedTab == "Image", let imageData = file.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 78, height: 78)
                            .clipped()
                            .cornerRadius(20)
                            .padding(5)
                    } else {
                        Image(systemName: worksViewModel.iconNameForType(file.type))
                            .font(Font.custom(size: 24, weight: .medium))
                            .foregroundColor(.darkPurple)
                            .padding()
                            .frame(width: 78, height: 78)
                            .background(Color.gray20)
                            .cornerRadius(20)
                            .padding(5)
                    }
                                
                    
                    VStack(alignment: .leading) {
                        Text(worksViewModel.last14Characters(of: file.fileName ?? "Unknown"))
                            .font(Font.custom(size: 16, weight: .bold))
                            .foregroundStyle(Color.black)
                            .lineLimit(1)
                        
                        HStack(spacing: 10) {
                            Text("\(file.fileSizeKB) KB")
                                .font(Font.custom(size: 14, weight: .regular))
                                .foregroundStyle(Color.gray40)
                            
                            Text(file.duration ?? "00:00")
                                .font(Font.custom(size: 14, weight: .regular))
                                .foregroundStyle(Color.gray40)
                        }
                    }
                    .padding(.leading, 6)
                    
                    Spacer()
                    
                    Menu {
                        Button("Add to Folder") {
                            worksViewModel.selectedFile = file
                            worksViewModel.showFolderPickerSheet = true
                        }
                        
                        Button("Share") {
                            worksViewModel.selectedFile = file
                            if let file = worksViewModel.selectedFile,
                               let filePath = file.fileURL {
                                
                                let fileURL = URL(fileURLWithPath: filePath)

                                if FileManager.default.fileExists(atPath: fileURL.path),
                                   let controller = ShareHelper.getRootController() {
                                    ShareManager.shared.shareFiles([fileURL], from: controller)
                                } else {
                                    print("🚫 File doesn't exist at path: \(fileURL.path)")
                                }
                            } else {
                                print("🚫 No selected file or invalid file path")
                            }

                        }
                        
                        Button("Delete", role: .destructive) {
                            worksViewModel.selectedFile = file
                            worksViewModel.alertType = .deleteFile
                        }
                    } label: {
                        Image("iconoir_more-horiz")
                            .padding(.trailing, 5)
                    }
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

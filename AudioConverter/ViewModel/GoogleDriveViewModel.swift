//
//  GoogleDriveViewModel.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI
//import GoogleSignIn
//import GoogleAPIClientForREST
//import GTMSessionFetcher

//class GoogleDriveViewModel: ObservableObject {
//    @Published var isSignedIn = false
//    @Published var driveFiles: [GTLRDrive_File] = []
//    @Published var downloadedImage: UIImage?
//
//    private let driveService = GTLRDriveService()
//    private let clientID = "873497851958-eu6tkteibi6vj1jqemvpgvnptk96d3so.apps.googleusercontent.com"
//
//    func signIn() {
//        guard let rootViewController = UIApplication.shared
//            .connectedScenes
//            .compactMap({ $0 as? UIWindowScene })
//            .flatMap({ $0.windows })
//            .first(where: { $0.isKeyWindow })?
//            .rootViewController else {
//                print("No root view controller found")
//                return
//        }
//
//        let configuration = GIDConfiguration(clientID: clientID)
//
//        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [weak self] user, error in
//            guard let self = self else { return }
//            
//            if let error = error {
//                print("Google Sign-In error: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let user = user else {
//                print("Missing user")
//                return
//            }
//               
//            let accessToken = user.authentication.accessToken
//            let authorizer = GTMFetcherAuthorizationWrapper(accessToken: accessToken)
//            self.driveService.authorizer = authorizer
//            self.isSignedIn = true
//            self.listDriveImages()
//        }
//    }
//
//    func listDriveImages() {
//        let query = GTLRDriveQuery_FilesList.query()
//        query.q = "mimeType contains 'image/' and trashed = false"
//        query.pageSize = 50
//        query.fields = "files(id, name, mimeType)"
//
//        driveService.executeQuery(query) { [weak self] (_, result, error) in
//            if let error = error {
//                print("Drive API error: \(error)")
//                return
//            }
//
//            if let filesList = result as? GTLRDrive_FileList {
//                DispatchQueue.main.async {
//                    self?.driveFiles = filesList.files ?? []
//                }
//            }
//        }
//    }
//
//    func downloadImage(file: GTLRDrive_File) {
//        guard let fileId = file.identifier else { return }
//
//        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)
//
//        driveService.executeQuery(query) { [weak self] (_, fileData, error) in
//            if let error = error {
//                print("Error downloading file: \(error)")
//                return
//            }
//
//            if let data = (fileData as? GTLRDataObject)?.data,
//               let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self?.downloadedImage = image
//                }
//            }
//        }
//    }
//}
//
//
//struct GoogleDriveView: View {
//    @StateObject var vm = GoogleDriveViewModel()
//
//    var body: some View {
//        VStack {
//            if vm.isSignedIn {
//                List(vm.driveFiles, id: \.identifier) { file in
//                    Button(file.name ?? "Unnamed") {
//                        vm.downloadImage(file: file)
//                    }
//                }
//
//                if let image = vm.downloadedImage {
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 200)
//                        .padding()
//                }
//            } else {
//                Button("Sign in with Google") {
//                    vm.signIn()
//                }
//                .padding()
//            }
//        }
//    }
//}

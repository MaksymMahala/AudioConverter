//
//  GoogleDriveViewModel.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import UIKit
import GoogleSignIn

struct DriveFile: Identifiable, Decodable {
    let id: String
    let name: String
    let mimeType: String
    let webContentLink: String?
}

class GoogleDriveViewModel: ObservableObject {
    @Published var files: [DriveFile] = []
    @Published var isLoading = false
    var accessToken: String = "" // <- Тут передаєш токен після Google Sign-In

    func fetchFiles() {
        isLoading = true
        let query = "(mimeType contains 'video/') and trashed = false"
        let fields = "files(id,name,mimeType,webContentLink)"
        let urlString = "https://www.googleapis.com/drive/v3/files?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&fields=\(fields)"

        var request = URLRequest(url: URL(string: urlString)!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let data = data {
                let decoder = JSONDecoder()
                if let response = try? decoder.decode([String: [DriveFile]].self, from: data),
                   let files = response["files"] {
                    DispatchQueue.main.async {
                        self.files = files
                    }
                }
            }
        }.resume()
    }
}

import GoogleSignInSwift

class GoogleSignInViewModel: ObservableObject {
    @Published var accessToken: String? = nil
    @Published var userEmail: String = ""

    func signIn() {
        guard let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })     // unwrap UIWindowScene
                .flatMap({ $0.windows })                  // беремо всі вікна
                .first(where: \.isKeyWindow)?.rootViewController else {
            return
        }

        let config = GIDConfiguration(clientID: "945973136262-8k0s811c7ip2cn0e4pfqgb7q4b56o38s.apps.googleusercontent.com")
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController,
            hint: nil,
            additionalScopes: ["https://www.googleapis.com/auth/drive.readonly"]
        ) { result, error in
            if let error = error {
                print("Google Sign-In failed: \(error)")
                return
            }

            guard let user = result?.user else { return }
            let token = user.accessToken.tokenString

            DispatchQueue.main.async {
                self.accessToken = token
            }
        }
    }
}


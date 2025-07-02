//
//  MediaTabViewModel.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import Foundation

final class MediaTabViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var selectedTab: MediaTab = .video
}

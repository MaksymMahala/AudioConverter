//
//  ShareManager.swift
//  AudioConverter
//
//  Created by Max on 05.07.2025.
//

import UIKit
import SwiftUI

final class ShareManager {
    static let shared = ShareManager()
    
    private init() {}

    func shareFiles(_ urls: [URL], from controller: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: urls, applicationActivities: nil)
        controller.present(activityVC, animated: true)
    }

    func shareImage(_ image: UIImage, from controller: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.present(activityVC, animated: true)
    }
}

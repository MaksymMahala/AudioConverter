//
//  ShareHelper.swift
//  AudioConverter
//
//  Created by Max on 05.07.2025.
//

import UIKit

struct ShareHelper {
    static func getRootController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first?.rootViewController?
            .topMostViewController()
    }
}

//
//  UIApplication.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import SwiftUI

extension UIApplication {
    var foregroundActiveScene: UIWindowScene? {
        return connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
    }
}

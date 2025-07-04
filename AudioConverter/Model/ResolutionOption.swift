//
//  ResolutionOption.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import SwiftUI
import CoreGraphics

struct ResolutionOption: Identifiable, Hashable {
    let id = UUID()
    let value: String
    let isPro: Bool

    var cgSizeGIF: CGSize {
        let components = value
            .replacingOccurrences(of: "×", with: "x")
            .split(separator: "x")
            .compactMap { Double($0) }

        if components.count == 2 {
            return CGSize(width: components[0], height: components[1])
        }
        return CGSize(width: 480, height: 720)
    }
    
    static func ==(lhs: ResolutionOption, rhs: ResolutionOption) -> Bool {
         return lhs.value == rhs.value
     }

     func hash(into hasher: inout Hasher) {
         hasher.combine(value)
     }

    init(value: String, isPro: Bool = false) {
        self.value = value
        self.isPro = isPro
    }

    init(size: CGSize, isPro: Bool = false) {
        self.value = "\(Int(size.width))x\(Int(size.height))"
        self.isPro = isPro
    }
}


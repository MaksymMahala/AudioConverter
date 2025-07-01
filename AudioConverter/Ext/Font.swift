//
//  Font.swift
//  AudioConverter
//
//  Created by Max on 29.06.2025.
//

import Foundation
import SwiftUI

extension Font {
    static func custom(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .medium:
            return .custom("MoriGothic-Medium", size: size)
        case .semibold:
            return .custom("MoriGothic-SemiBold", size: size)
        case .bold:
            return .custom("MoriGothic-Bold", size: size)
        default:
            return .custom("MoriGothic-Regular", size: size)
        }
    }

    static var titleMori32: Font {
        .custom("MoriGothic-Bold", size: 32)
    }

    static var bodyMori: Font {
        .custom("MoriGothic-Regular", size: 16)
    }
}

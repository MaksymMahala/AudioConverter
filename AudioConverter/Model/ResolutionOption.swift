//
//  ResolutionOption.swift
//  AudioConverter
//
//  Created by Max on 03.07.2025.
//

import Foundation

struct ResolutionOption: Identifiable, Equatable {
    let id = UUID()
    let value: String
    let isPro: Bool
    
    static func ==(lhs: ResolutionOption, rhs: ResolutionOption) -> Bool {
        lhs.value == rhs.value && lhs.isPro == rhs.isPro
    }
}

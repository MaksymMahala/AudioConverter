//
//  Resolution+Ext.swift
//  AudioConverter
//
//  Created by Max on 04.07.2025.
//

import Foundation

extension ResolutionOption {
    var cgSize: CGSize {
        let parts = value.split(separator: "*")
        if parts.count == 2,
           let width = Double(parts[0]),
           let height = Double(parts[1]) {
            return CGSize(width: width, height: height)
        }
        return CGSize(width: 480, height: 720)
    }
}

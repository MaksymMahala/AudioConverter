//
//  SettingsRow.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import SwiftUI

struct SettingsRow: View {
    let option: SettingsOption
    
    var body: some View {
        HStack {
            Image(option.icon)
                .frame(width: 24, height: 24)
            
            Text(option.title)
                .font(Font.custom(size: 16, weight: .medium))
                .foregroundColor(.gray50)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray50)
        }
        .padding(.vertical, 14)
        .padding(.horizontal)
    }
}

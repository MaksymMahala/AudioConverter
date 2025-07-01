//
//  ToolCard.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct ToolCard: View {
    let tool: ToolItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image(tool.iconName)
            VStack(alignment: .leading, spacing: 6) {
                Text(tool.title)
                    .font(Font.custom(size: 16, weight: .bold))
                    .foregroundColor(.black)
                if !tool.subtitle.isEmpty {
                    Text(tool.subtitle)
                        .font(Font.custom(size: 12, weight: .medium))
                        .foregroundColor(.gray50)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(Color.grayF7F8FA)
        .cornerRadius(16)
    }
}

struct ToolCardHorizontal: View {
    let tool: ToolItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Text(tool.title)
                .font(Font.custom(size: 16, weight: .bold))
                .foregroundColor(.black)
            Image(tool.iconName)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.grayF7F8FA)
        .cornerRadius(16)
    }
}

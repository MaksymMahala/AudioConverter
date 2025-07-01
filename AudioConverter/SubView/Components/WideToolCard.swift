//
//  WideToolCard.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//
import SwiftUI

struct WideToolCard: View {
    let tool: ToolItem

    var body: some View {
        HStack {
            Text(tool.title)
                .font(Font.custom(size: 16, weight: .bold))
                .foregroundColor(.black)
            Spacer()
            Image(tool.iconName)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(Color.grayF7F8FA)
        .cornerRadius(16)
    }
}

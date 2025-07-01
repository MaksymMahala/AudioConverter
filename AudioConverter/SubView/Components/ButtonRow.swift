//
//  ButtonRow.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct ButtonRow: View {
    let title: String
    let image: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(image)
                Text(title)
                    .font(Font.custom(size: 16, weight: .medium))
                    .foregroundStyle(Color.black)
                
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.gray40)
            }
            .padding()
            .padding(.vertical)
            .background(Color.grayF7F8FA)
            .cornerRadius(20)
        }
    }
}

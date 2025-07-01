//
//  AudioToolsView.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI

struct AudioToolsView: View {
    @StateObject private var viewModel = AudioConversionViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label {
                Text("Audio")
                    .foregroundStyle(Color.darkBlueD90)
                    .font(Font.custom(size: 18, weight: .bold))
            } icon: {
                Image(.iconoirPlay)
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.tools) { tool in
                    Button {
                    } label: {
                        ToolCard(tool: tool)
                    }
                }
            }
            .padding(.horizontal)
            
            Button {
            } label: {
                WideToolCard(tool: viewModel.bottomTool)
            }
            .padding(.horizontal)
        }
    }
}

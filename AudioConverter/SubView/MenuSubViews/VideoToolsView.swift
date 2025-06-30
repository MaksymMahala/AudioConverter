//
//  VideoToolsView.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import SwiftUI

struct VideoToolsView: View {
    @StateObject private var viewModel = VideoToolsViewModel()
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(.iconoirVideo)
                Text("Video")
            }
            .foregroundStyle(Color.darkBlueD90)
            .font(Font.custom(size: 18, weight: .bold))
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.tools) { tool in
                    Button {
                        withAnimation {
                            
                        }
                    } label: {
                        ToolCard(tool: tool)
                    }
                }
            }
            .padding(.top, 10)
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.toolsHorizontal) { tool in
                    Button {
                        withAnimation {
                            
                        }
                    } label: {
                        ToolCardHorizontal(tool: tool)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 6)
        }
    }
}

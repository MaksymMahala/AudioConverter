//
//  WaveformView.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import Foundation
import SwiftUI

struct WaveformView: View {
    let amplitudes: [CGFloat]
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let barWidth = geometry.size.width / CGFloat(amplitudes.count)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 1) {
                    ForEach(amplitudes.indices, id: \.self) { i in
                        let height = amplitudes[i] * geometry.size.height
                        Rectangle()
                            .fill(i < Int(CGFloat(amplitudes.count) * progress) ? Color.purple : Color.gray.opacity(0.3))
                            .frame(width: barWidth, height: height)
                            .offset(y: (geometry.size.height - height) / 2)
                    }
                }
            }
        }
        .clipped()
    }
}

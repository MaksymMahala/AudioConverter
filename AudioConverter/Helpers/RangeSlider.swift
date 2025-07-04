//
//  RangeSlider.swift
//  AudioConverter
//
//  Created by Max on 04.07.2025.
//

import SwiftUI

struct RangeSlider: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let range: ClosedRange<Double>
       
    var onEditingChanged: ((Bool) -> Void)? = nil
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                let trackWidth = geo.size.width
                let rangeSpan = range.upperBound - range.lowerBound
                
                let lower = CGFloat((minValue - range.lowerBound) / rangeSpan) * trackWidth
                let upper = CGFloat((maxValue - range.lowerBound) / rangeSpan) * trackWidth
                
                let selectedWidth = max(0, upper - lower)
                Capsule()
                    .fill(Color.darkPurple)
                    .frame(width: selectedWidth, height: 4)
                    .offset(x: lower)
                
                let handleSize: CGFloat = 20
                
                Circle()
                    .fill(Color.white)
                    .frame(width: handleSize, height: handleSize)
                    .shadow(radius: 1)
                    .position(x: lower, y: geo.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                onEditingChanged?(true)
                                let clampedX = min(max(value.location.x, 0), upper)
                                let percent = clampedX / trackWidth
                                let newValue = Double(percent) * rangeSpan + range.lowerBound
                                minValue = min(newValue, maxValue)
                            }
                            .onEnded { _ in
                                onEditingChanged?(false)
                            }
                    )
                
                Circle()
                    .fill(Color.white)
                    .frame(width: handleSize, height: handleSize)
                    .shadow(radius: 1)
                    .position(x: upper, y: geo.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                onEditingChanged?(true) 
                                let clampedX = max(min(value.location.x, trackWidth), lower)
                                let percent = clampedX / trackWidth
                                let newValue = Double(percent) * rangeSpan + range.lowerBound
                                maxValue = max(newValue, minValue)
                            }
                            .onEnded { _ in
                                onEditingChanged?(false)
                            }
                    )
                
            }
        }
    }
}

//
//  DraggableText.swift
//  FewCuts
//
//  Created by 송영모 on 6/13/25.
//

import SwiftUI

public struct TextDraggable: Draggable {
    public var id: DraggableID = .init()
    public var rect: CGRect
    public var rotation: Angle
    public var originalRotation: CGFloat
    
    public var text: String
    
    public init(
        id: DraggableID = .init(),
        rect: CGRect,
        rotation: Angle = .zero,
        originalRotation: CGFloat = 0,
        text: String
    ) {
        self.id = id
        self.rect = rect
        self.rotation = rotation
        self.originalRotation = originalRotation
        self.text = text
    }
    
    private var fontSize: CGFloat {
        let baseSize = min(rect.width, rect.height)
        return max(12, baseSize * 0.3)
    }
    
    @ViewBuilder
    public func createView(index: Int, color: Color) -> some View {
        Text(text)
            .font(.system(size: fontSize, weight: .bold, design: .default))
            .foregroundColor(color)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .frame(width: rect.width, height: rect.height)
            .rotationEffect(rotation)
            .position(x: rect.midX, y: rect.midY)
            .allowsHitTesting(false)
    }
}

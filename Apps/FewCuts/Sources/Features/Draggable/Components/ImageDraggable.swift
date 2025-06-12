//
//  DraggableImage.swift
//  FewCuts
//
//  Created by 송영모 on 6/13/25.
//

import SwiftUI

public struct ImageDraggable: Draggable {
    public var id: DraggableID = .init()
    public var rect: CGRect
    public var rotation: Angle
    public var originalRotation: CGFloat
    
    public var systemImageName: String

    public init(
        id: DraggableID = .init(),
        rect: CGRect,
        rotation: Angle = .zero,
        originalRotation: CGFloat = 0,
        systemImageName: String
    ) {
        self.id = id
        self.rect = rect
        self.rotation = rotation
        self.originalRotation = originalRotation
        self.systemImageName = systemImageName
    }
    
    @ViewBuilder
    public func createView(index: Int, color: Color) -> some View {
        Image(systemName: systemImageName)
            .font(.system(size: min(rect.width, rect.height) * 0.8))
            .foregroundColor(color)
            .frame(width: rect.width, height: rect.height)
            .rotationEffect(rotation)
            .position(x: rect.midX, y: rect.midY)
            .allowsHitTesting(false)
    }
}

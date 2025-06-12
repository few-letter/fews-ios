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
}

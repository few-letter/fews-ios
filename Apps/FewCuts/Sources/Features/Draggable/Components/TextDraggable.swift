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
}

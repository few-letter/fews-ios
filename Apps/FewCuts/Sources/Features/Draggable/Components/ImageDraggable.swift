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
    
    // 이미지 사이즈 인터셉터 - 정사각형 비율 유지 (옵션)
    public func interceptSizeChange(newRect: CGRect) -> CGRect {
        // 이미지의 경우 사용자가 설정한 크기 그대로 사용
        // 원한다면 정사각형 비율 강제할 수도 있음
        return newRect
        
        // 정사각형 비율 강제 예시:
        // let size = min(newRect.width, newRect.height)
        // return CGRect(origin: newRect.origin, size: CGSize(width: size, height: size))
    }
    
    // 회전 인터셉터 - 기본 동작 유지
    public func interceptRotationChange(newRotation: Angle, newOriginalRotation: CGFloat) -> (Angle, CGFloat) {
        return (newRotation, newOriginalRotation)
    }
}

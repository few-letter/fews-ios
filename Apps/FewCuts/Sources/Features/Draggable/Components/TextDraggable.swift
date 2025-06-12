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
            .border(.black)
            .font(.system(size: fontSize, weight: .bold, design: .default))
            .foregroundColor(color)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .frame(width: rect.width, height: rect.height)
            .rotationEffect(rotation)
            .position(x: rect.midX, y: rect.midY)
            .allowsHitTesting(false)
    }
    
    // 텍스트 전용 사이즈 인터셉터 - 폰트 크기에 맞는 최적 크기로 조정
    public func interceptSizeChange(newRect: CGRect) -> CGRect {
        let targetFontSize = max(12, min(newRect.width, newRect.height) * 0.3)
        
        // 텍스트 크기 측정
        let text = self.text as NSString
        let font = UIFont.systemFont(ofSize: targetFontSize, weight: .bold)
        let attributes = [NSAttributedString.Key.font: font]
        
        // 여러 줄 텍스트를 고려한 크기 계산
        let maxWidth = newRect.width
        let boundingRect = text.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        // 여백을 고려한 최적 크기 (하지만 사용자가 원하는 크기도 존중)
        let padding: CGFloat = 16
        let minWidth = max(boundingRect.width + padding, 60)
        let minHeight = max(boundingRect.height + padding, 40)
        
        // 사용자가 설정한 크기와 텍스트 필요 크기 중 더 큰 값 사용
        let finalWidth = max(newRect.width, minWidth)
        let finalHeight = max(newRect.height, minHeight)
        
        return CGRect(
            origin: newRect.origin,
            size: CGSize(width: finalWidth, height: finalHeight)
        )
    }
    
    // 회전 인터셉터 - 기본 동작 유지
    public func interceptRotationChange(newRotation: Angle, newOriginalRotation: CGFloat) -> (Angle, CGFloat) {
        return (newRotation, newOriginalRotation)
    }
}

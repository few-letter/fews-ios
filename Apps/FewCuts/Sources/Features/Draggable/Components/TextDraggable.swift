//
//  DraggableText.swift
//  FewCuts
//
//  Created by 송영모 on 6/13/25.
//

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
    
    // 텍스트에 맞는 최적 폰트 크기 계산
    private func optimalFontSize(for rect: CGRect) -> CGFloat {
        let padding: CGFloat = 8 // 테두리와의 여백
        let availableWidth = rect.width - padding
        let availableHeight = rect.height - padding
        
        // 최소/최대 폰트 크기 제한
        let minFontSize: CGFloat = 8
        let maxFontSize: CGFloat = 72
        
        // 이진 탐색으로 최적 폰트 크기 찾기
        var low = minFontSize
        var high = maxFontSize
        var bestSize = minFontSize
        
        while low <= high {
            let mid = (low + high) / 2
            let textSize = calculateTextSize(fontSize: mid, maxWidth: availableWidth)
            
            if textSize.width <= availableWidth && textSize.height <= availableHeight {
                bestSize = mid
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        
        return bestSize
    }
    
    // 주어진 폰트 크기로 텍스트 크기 계산
    private func calculateTextSize(fontSize: CGFloat, maxWidth: CGFloat) -> CGSize {
        let text = self.text as NSString
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let attributes = [NSAttributedString.Key.font: font]
        
        let boundingRect = text.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        return boundingRect.size
    }
    
    private var fontSize: CGFloat {
        return optimalFontSize(for: rect)
    }
    
    @ViewBuilder
    public func createView(index: Int, color: Color) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: rect.width, height: rect.height)
            .border(.black, width: 1)
            .overlay(
                Text(text)
                    .font(.system(size: fontSize, weight: .bold, design: .default))
                    .foregroundColor(color)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(4) // 테두리와의 여백
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            )
            .rotationEffect(rotation)
            .position(x: rect.midX, y: rect.midY)
            .allowsHitTesting(false)
    }
    
    // 텍스트에 맞는 최적 크기로 조정
    public func interceptSizeChange(newRect: CGRect) -> CGRect {
        // 최소 크기 제한
        let minWidth: CGFloat = 60
        let minHeight: CGFloat = 40
        
        // 텍스트 내용에 따른 권장 크기 계산
        let padding: CGFloat = 16
        
        // 여러 폰트 크기로 테스트해서 적절한 크기 찾기
        let testFontSize: CGFloat = 16 // 기준 폰트 크기
        let textSize = calculateTextSize(fontSize: testFontSize, maxWidth: max(newRect.width - padding, 100))
        
        let recommendedWidth = textSize.width + padding
        let recommendedHeight = textSize.height + padding
        
        // 사용자가 설정한 크기와 권장 크기 중 적절한 값 선택
        let finalWidth = max(newRect.width, max(minWidth, recommendedWidth))
        let finalHeight = max(newRect.height, max(minHeight, recommendedHeight))
        
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

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
    
    @State public var text: String
    @State private var editingText: String = ""
    
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
        self._text = State(initialValue: text)
    }
    
    // 텍스트에 맞는 최적 폰트 크기 계산 (더 정확한 계산)
    private func optimalFontSize(for rect: CGRect) -> CGFloat {
        let padding: CGFloat = 12 // 좀 더 넉넉한 패딩
        let availableWidth = rect.width - padding
        let availableHeight = rect.height - padding
        
        // 최소/최대 폰트 크기 제한
        let minFontSize: CGFloat = 8
        let maxFontSize: CGFloat = 72
        
        // 더 정확한 이진 탐색
        var low = minFontSize
        var high = maxFontSize
        var bestSize = minFontSize
        
        // 더 세밀한 탐색을 위해 반복 횟수 증가
        for _ in 0..<20 {
            let mid = (low + high) / 2
            let textSize = calculateTextSize(fontSize: mid, maxWidth: availableWidth)
            
            if textSize.width <= availableWidth && textSize.height <= availableHeight {
                bestSize = mid
                low = mid + 0.5
            } else {
                high = mid - 0.5
            }
            
            if high - low < 0.5 {
                break
            }
        }
        
        return max(bestSize, minFontSize)
    }
    
    // 더 정확한 텍스트 크기 계산
    private func calculateTextSize(fontSize: CGFloat, maxWidth: CGFloat) -> CGSize {
        let nsString = text as NSString
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        
        let constraintSize = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingRect = nsString.boundingRect(
            with: constraintSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading, .usesDeviceMetrics],
            attributes: attributes,
            context: nil
        )
        
        // 실제 렌더링을 고려한 약간의 여백 추가
        return CGSize(
            width: ceil(boundingRect.width) + 2,
            height: ceil(boundingRect.height) + 2
        )
    }
    
    private var fontSize: CGFloat {
        return optimalFontSize(for: rect)
    }
    
    // 텍스트가 변경되었을 때 크기 자동 조정
    private func adjustSizeToFitText() -> CGRect {
        let padding: CGFloat = 16
        let targetFontSize: CGFloat = 16 // 기본 폰트 크기
        
        let textSize = calculateTextSize(fontSize: targetFontSize, maxWidth: CGFloat.greatestFiniteMagnitude)
        
        let newWidth = max(textSize.width + padding, 80) // 최소 너비
        let newHeight = max(textSize.height + padding, 40) // 최소 높이
        
        return CGRect(
            origin: rect.origin,
            size: CGSize(width: newWidth, height: newHeight)
        )
    }
    
    @ViewBuilder
    public func createView(index: Int, color: Color) -> some View {
        createView(index: index, color: color, isEditing: false, onEditingChanged: { _ in })
    }
    
    @ViewBuilder
    public func createView(index: Int, color: Color, isEditing: Bool, onEditingChanged: @escaping (Bool) -> Void) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: rect.width, height: rect.height)
            .border(.black, width: isEditing ? 2 : 1)
            .overlay(
                Group {
                    if isEditing {
                        TextField("텍스트 입력", text: $editingText)
                            .font(.system(size: fontSize, weight: .bold, design: .default))
                            .foregroundColor(color)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(6)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(4)
                            .onSubmit {
                                text = editingText
                                onEditingChanged(false)
                                // 텍스트 변경 후 크기 조정이 필요하다면 여기서 처리
                            }
                            .onAppear {
                                editingText = text
                            }
                            .onDisappear {
                                // 편집 모드 종료 시에도 텍스트 저장
                                if text != editingText {
                                    text = editingText
                                }
                            }
                    } else {
                        Text(text)
                            .font(.system(size: fontSize, weight: .bold, design: .default))
                            .foregroundColor(color)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .padding(6)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.clear)
                            .contentShape(Rectangle())
                    }
                }
            )
            .rotationEffect(rotation)
            .position(x: rect.midX, y: rect.midY)
            .allowsHitTesting(isEditing)
    }
    
    // 텍스트에 맞는 최적 크기로 조정 (더 정확한 계산)
    public func interceptSizeChange(newRect: CGRect) -> CGRect {
        let minWidth: CGFloat = 80
        let minHeight: CGFloat = 40
        
        // 현재 텍스트에 맞는 최소 크기 계산
        let padding: CGFloat = 16
        let testFontSize: CGFloat = 14
        let textSize = calculateTextSize(fontSize: testFontSize, maxWidth: max(newRect.width - padding, 100))
        
        let recommendedWidth = textSize.width + padding
        let recommendedHeight = textSize.height + padding
        
        // 사용자가 지정한 크기를 존중하되, 최소 크기는 보장
        let finalWidth = max(newRect.width, max(minWidth, min(recommendedWidth, newRect.width + 50)))
        let finalHeight = max(newRect.height, max(minHeight, min(recommendedHeight, newRect.height + 20)))
        
        return CGRect(
            origin: newRect.origin,
            size: CGSize(width: finalWidth, height: finalHeight)
        )
    }
    
    // 회전 인터셉터 - 기본 동작 유지
    public func interceptRotationChange(newRotation: Angle, newOriginalRotation: CGFloat) -> (Angle, CGFloat) {
        return (newRotation, newOriginalRotation)
    }
    
    // 텍스트 변경 시 호출되는 메서드 (필요시 사용)
    public mutating func updateText(_ newText: String) {
        text = newText
        // 필요시 크기 자동 조정
        // rect = adjustSizeToFitText()
    }
}

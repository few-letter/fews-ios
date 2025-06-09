//  DraggableContainerView.swift
//  FewCuts
//
//  Created by 송영모 on 6/9/25.
//

import SwiftUI

public struct DraggableContainerView<Content: View>: View {
    public let parentSize: CGSize
    @Binding public var rect: CGRect
    public let isSelected: Bool
    public let onTapped: () -> Void
    public let content: Content

    @State private var initialRect: CGRect?

    public init(
        parentSize: CGSize,
        rect: Binding<CGRect>,
        isSelected: Bool = false,
        onTapped: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.parentSize = parentSize
        self._rect = rect
        self.isSelected = isSelected
        self.onTapped = onTapped
        self.content = content()
    }

    public var body: some View {
        content
            .background(selectionBackground)
            .frame(width: rect.width, height: rect.height)
            .overlay(alignment: .bottomTrailing) {
                if isSelected {
                    cornerHandle
                }
            }
            .offset(x: rect.origin.x, y: rect.origin.y)
            .gesture(dragGesture)
    }

    private var selectionBackground: some View {
        RoundedRectangle(cornerRadius: 4)
            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(4)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                onTapped()
                if initialRect == nil {
                    initialRect = rect
                }
                let newOrigin = CGPoint(
                    x: initialRect!.origin.x + value.translation.width,
                    y: initialRect!.origin.y + value.translation.height
                )
                rect.origin = clamp(newOrigin, size: rect.size)
            }
            .onEnded { _ in initialRect = nil }
    }

    private var cornerHandle: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 16, height: 16)
            .shadow(radius: 2)
            .offset(x: 8, y: 8)
            .padding(12)
            .contentShape(Rectangle())
            .gesture(cornerDragGesture)
    }

    private var cornerDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if initialRect == nil {
                    initialRect = rect
                }
                let deltaX = value.translation.width
                let deltaY = value.translation.height

                // 새 크기 계산 (최소 50)
                let newW = max(50, initialRect!.width  + deltaX)
                let newH = max(50, initialRect!.height + deltaY)

                // 부모 경계를 넘지 않도록
                let maxW = parentSize.width  - initialRect!.origin.x
                let maxH = parentSize.height - initialRect!.origin.y

                rect.size = CGSize(
                    width: min(newW, maxW),
                    height: min(newH, maxH)
                )
            }
            .onEnded { _ in initialRect = nil }
    }

    private func clamp(_ origin: CGPoint, size: CGSize) -> CGPoint {
        let x = min(max(0, origin.x), parentSize.width  - size.width)
        let y = min(max(0, origin.y), parentSize.height - size.height)
        return CGPoint(x: x, y: y)
    }
}

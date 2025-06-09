//
//  DraggableContainerView.swift
//  FewCuts
//
//  Created by 송영모 on 6/9/25.
//

import SwiftUI

public struct DraggableContainerView<Content: View>: View {
    let parentSize: CGSize
    @Binding var rect: CGRect
    @Binding var rotation: Double
    let isSelected: Bool
    let onTapped: () -> Void
    let content: Content

    @State private var dragStartOrigin: CGPoint?
    @State private var resizeStartRect: CGRect?
    @State private var rotationStartAngle: Double?
    @State private var isResizing = false
    @State private var isRotating = false

    public init(
        parentSize: CGSize,
        rect: Binding<CGRect>,
        rotation: Binding<Double> = .constant(0),
        isSelected: Bool = false,
        onTapped: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.parentSize = parentSize
        self._rect = rect
        self._rotation = rotation
        self.isSelected = isSelected
        self.onTapped = onTapped
        self.content = content()
    }

    public var body: some View {
        ZStack {
            content
                .frame(width: rect.width, height: rect.height)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                        )
                )
                .rotationEffect(.degrees(rotation))
                .position(x: rect.midX, y: rect.midY)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            onTapped()
                            if !isResizing && !isRotating { startOrMoveDrag(value) }
                        }
                        .onEnded { _ in endDrag() }
                )

            if isSelected {
                resizeHandle
            }
        }
        .frame(width: parentSize.width, height: parentSize.height)
        .clipped()
    }

    private var resizeHandle: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 25, height: 25)
                .position(x: rect.maxX - 12, y: rect.maxY - 12)
                .gesture(
                    DragGesture(minimumDistance: 2)
                        .onChanged { handleResize($0) }
                        .onEnded { _ in endResize() }
                )
            
            Rectangle()
                .fill(Color.clear)
                .frame(width: 25, height: 25)
                .position(x: rect.maxX + 8, y: rect.maxY + 8)
                .gesture(
                    DragGesture(minimumDistance: 2)
                        .onChanged { handleRotation($0) }
                        .onEnded { _ in endRotation() }
                )

            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.blue)
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 14, height: 14)
                        .shadow(radius: 1)
                )
                .position(x: rect.maxX - 12, y: rect.maxY - 12)
            
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.green)
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 14, height: 14)
                        .shadow(radius: 1)
                )
                .position(x: rect.maxX + 8, y: rect.maxY + 8)
        }
    }

    private func startOrMoveDrag(_ value: DragGesture.Value) {
        if dragStartOrigin == nil {
            dragStartOrigin = rect.origin
        }
        let base = dragStartOrigin!
        let moved = CGPoint(
            x: base.x + value.translation.width,
            y: base.y + value.translation.height
        )
        rect.origin = clamp(moved, size: rect.size)
    }

    private func endDrag() {
        dragStartOrigin = nil
    }

    private func handleResize(_ value: DragGesture.Value) {
        if !isResizing {
            isResizing = true
            resizeStartRect = rect
        }
        guard let start = resizeStartRect else { return }
        var newRect = start
        newRect.size.width = max(50, start.size.width + value.translation.width)
        newRect.size.height = max(50, start.size.height + value.translation.height)
        rect = constrain(newRect)
    }

    private func endResize() {
        isResizing = false
        resizeStartRect = nil
    }
    
    private func handleRotation(_ value: DragGesture.Value) {
        if !isRotating {
            isRotating = true
            rotationStartAngle = rotation
        }
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let currentLocation = CGPoint(
            x: rect.maxX + 8 + value.translation.width,
            y: rect.maxY + 8 + value.translation.height
        )
        
        let angle = atan2(currentLocation.y - center.y, currentLocation.x - center.x)
        let degrees = angle * 180 / .pi
        
        let snappedDegrees = round(degrees / 15) * 15
        rotation = snappedDegrees
    }
    
    private func endRotation() {
        isRotating = false
        rotationStartAngle = nil
    }

    private func clamp(_ origin: CGPoint, size: CGSize) -> CGPoint {
        let x = min(max(origin.x, 0), parentSize.width - size.width)
        let y = min(max(origin.y, 0), parentSize.height - size.height)
        return CGPoint(x: x, y: y)
    }

    private func constrain(_ rect: CGRect) -> CGRect {
        var r = rect
        if r.origin.x < 0 { r.size.width += r.origin.x; r.origin.x = 0 }
        if r.origin.y < 0 { r.size.height += r.origin.y; r.origin.y = 0 }
        if r.maxX > parentSize.width { r.size.width = parentSize.width - r.origin.x }
        if r.maxY > parentSize.height { r.size.height = parentSize.height - r.origin.y }
        return r
    }
}

////  DraggableContainerView.swift
////  FewCuts
////
////  Created by 송영모 on 6/9/25.
////
//
//import SwiftUI
//
//enum RectCorner {
//    case topLeft, topRight, bottomLeft, bottomRight
//}
//
//public struct DraggableContainerView<Content: View>: View {
//    public let parentSize: CGSize
//    @Binding public var rect: CGRect
//    public let isSelected: Bool
//    public let onTapped: () -> Void
//    public let content: Content
//
//    @State private var initialRect: CGRect?
//    @State private var draggedCorner: RectCorner?
//
//    public init(
//        parentSize: CGSize,
//        rect: Binding<CGRect>,
//        isSelected: Bool = false,
//        onTapped: @escaping () -> Void = {},
//        @ViewBuilder content: () -> Content
//    ) {
//        self.parentSize = parentSize
//        self._rect = rect
//        self.isSelected = isSelected
//        self.onTapped = onTapped
//        self.content = content()
//    }
//
//    public var body: some View {
//        content
//            .background(selectionBackground)
//            .frame(width: rect.width, height: rect.height)
//            .overlay(alignment: .bottomTrailing) {
//                if isSelected {
//                    cornerHandle
//                }
//            }
//            .offset(x: rect.origin.x, y: rect.origin.y)
//            .gesture(dragGesture)
//    }
//
//    private var selectionBackground: some View {
//        RoundedRectangle(cornerRadius: 4)
//            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
//            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
//            .cornerRadius(4)
//    }
//
//    private var dragGesture: some Gesture {
//        DragGesture(minimumDistance: 10)
//            .onChanged { value in
//                onTapped()
//                if initialRect == nil {
//                    initialRect = rect
//                }
//                let newOrigin = CGPoint(
//                    x: initialRect!.origin.x + value.translation.width,
//                    y: initialRect!.origin.y + value.translation.height
//                )
//                rect.origin = clamp(newOrigin, size: rect.size)
//            }
//            .onEnded { _ in initialRect = nil }
//    }
//
//    private var cornerHandle: some View {
//        Circle()
//            .fill(Color.white)
//            .frame(width: 16, height: 16)
//            .shadow(radius: 2)
//            .offset(x: 8, y: 8)
//            .padding(12)
//            .contentShape(Rectangle())
//            .gesture(cornerDragGesture)
//    }
//
//    private var cornerDragGesture: some Gesture {
//        DragGesture()
//            .onChanged { value in
//                if initialRect == nil {
//                    initialRect = rect
//                    draggedCorner = .bottomRight // 코너 핸들은 항상 bottomRight
//                }
//                
//                if let draggedCorner {
//                    rect = dragResize(
//                        initialRect: initialRect!,
//                        draggedCorner: draggedCorner,
//                        frameSize: parentSize,
//                        translation: value.translation
//                    )
//                }
//            }
//            .onEnded { _ in 
//                initialRect = nil
//                draggedCorner = nil
//            }
//    }
//
//    private func clamp(_ origin: CGPoint, size: CGSize) -> CGPoint {
//        let x = min(max(0, origin.x), parentSize.width  - size.width)
//        let y = min(max(0, origin.y), parentSize.height - size.height)
//        return CGPoint(x: x, y: y)
//    }
//    
//    private func dragResize(initialRect: CGRect, draggedCorner: RectCorner, frameSize: CGSize, translation: CGSize) -> CGRect {
//        let minSize = CGSize(width: 50, height: 50)
//        var offX = 1.0
//        var offY = 1.0
//
//        switch draggedCorner {
//        case .topLeft:      offX = -1;  offY = -1
//        case .topRight:                 offY = -1
//        case .bottomLeft:   offX = -1
//        case .bottomRight: break
//        }
//
//        let idealWidth = initialRect.size.width + offX * translation.width
//        var newWidth = max(idealWidth, minSize.width)
//
//        let maxHeight = frameSize.height - initialRect.minY
//        let idealHeight = initialRect.size.height + offY * translation.height
//        var newHeight = max(idealHeight, minSize.height)
//
//        var newX = initialRect.minX
//        var newY = initialRect.minY
//
//        if offX < 0 {
//            let widthChange = newWidth - initialRect.width
//            newX = max(newX - widthChange, 0)
//            newWidth = min(newWidth, initialRect.maxX)
//        } else {
//            newWidth = min(newWidth, frameSize.width - initialRect.minX)
//        }
//
//        if offY < 0 {
//            let heightChange = newHeight - initialRect.height
//            newY = max(newY - heightChange, 0)
//            newHeight = min(initialRect.maxY, newHeight)
//        } else {
//            newHeight = min(newHeight, maxHeight)
//        }
//
//        return .init(origin: .init(x: newX, y: newY), size: .init(width: newWidth, height: newHeight))
//    }
//}

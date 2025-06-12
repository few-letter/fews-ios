//
//  DraggableView.swift
//  FewCuts
//
//  Created by 송영모 on 6/12/25.
//

import SwiftUI
import UIKit
import Observation

// MARK: - 드래그 가능한 아이템 모델

public struct DraggableItem: Identifiable {
    public let id = UUID()
    public var rect: CGRect
    public var rotation: Angle = .zero
    public var originalRotation: CGFloat = 0 // 원본 기준 누적 회전각도 (라디안)
    
    public init(rect: CGRect, rotation: Angle = .zero, originalRotation: CGFloat = 0) {
        self.rect = rect
        self.rotation = rotation
        self.originalRotation = originalRotation
    }
}

// MARK: - 그리드 모델

public enum GridOrientation {
    case vertical, horizontal
}

public struct GridLine: Identifiable {
    public let id = UUID()
    public let orientation: GridOrientation
    public let position: CGFloat     // x 또는 y
    
    public init(orientation: GridOrientation, position: CGFloat) {
        self.orientation = orientation
        self.position = position
    }
}

// MARK: - 터치 모드

private enum TouchMode {
    case dragging, resizing
}

// MARK: - 드래그 관리자

@Observable
public final class DragManager: MultiTouchDelegate {
    // ────── 그리드 임계치(손맛 조절) ──────
    private let activateThreshold: CGFloat = 1    // 라인 강조 시작
    private let stickyThreshold: CGFloat = 1      // 살짝 끌어당김
    private let snapThreshold: CGFloat = 1        // 완전 스냅
    private let rotateThresholdDeg: CGFloat = 10
    
    // ────── 회전 스냅 설정 ──────
    private let rotationSnapThreshold: CGFloat = 5
    private let rotationSnapAngles: [CGFloat] = [0, 90, 180, 270, 360]
    
    // ────── 외부 노출 상태 ──────
    public var items: [DraggableItem]
    public let gridLines: [GridLine]
    public var activeLineIDs: Set<UUID> = []
    
    public var isDraggingActive: Bool { !draggingItems.isEmpty }
    public var isResizingActive: Bool { !resizingItems.isEmpty }
    public var isGridActive: Bool { !activeLineIDs.isEmpty }
    
    // 드래그
    private var draggingItems: [UITouch: DraggableItem] = [:]
    private var initialPositions: [UITouch: CGPoint] = [:]
    
    // 리사이즈 - 회전
    private var resizingItems: [UITouch: DraggableItem] = [:]
    private var initialSizes: [UITouch: CGSize] = [:]
    private var initialRotations: [UITouch: CGFloat] = [:]
    private var anchorTouches: [UITouch: UITouch] = [:] // second → first
    private var anchorRatios: [UITouch: CGPoint] = [:]
    private var initialAnchorDistances: [UITouch: CGFloat] = [:]
    private var startAngles: [UITouch: CGFloat] = [:]
    
    private var touchModes: [UITouch: TouchMode] = [:]
    
    // ────────────────
    public init(items: [DraggableItem] = [], gridLines: [GridLine] = []) {
        self.items = items
        self.gridLines = gridLines
    }
}

// MARK: - MultiTouchDelegate 구현

extension DragManager {
    public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView?) {
        guard let view else { return }
        for touch in touches {
            let loc = touch.location(in: view)
            
            // 이미 드래그 중이면 두 번째 손가락 → 리사이즈/회전
            if let anchor = draggingItems.keys.first,
               let anchorItem = draggingItems[anchor] {
                resizingItems[touch] = anchorItem
                touchModes[touch] = .resizing
                
                if let idx = items.firstIndex(where: { $0.id == anchorItem.id }) {
                    initialSizes[touch] = items[idx].rect.size
                    initialRotations[touch] = items[idx].originalRotation
                    
                    // 앵커 비율(고정점)
                    let anchorLoc = anchor.location(in: view)
                    let r = items[idx].rect
                    anchorRatios[touch] = CGPoint(
                        x: (anchorLoc.x - r.minX) / r.width,
                        y: (anchorLoc.y - r.minY) / r.height
                    )
                    
                    // 초기 거리/각
                    initialAnchorDistances[touch] = max(
                        hypot(loc.x - anchorLoc.x, loc.y - anchorLoc.y), 1
                    )
                    anchorTouches[touch] = anchor
                    startAngles[touch] = atan2(loc.y - anchorLoc.y, loc.x - anchorLoc.x)
                }
            }
            // 첫 손가락 드래그 스타트
            else if let item = items.reversed().first(where: { $0.rect.contains(loc) }) {
                draggingItems[touch] = item
                initialPositions[touch] = item.rect.origin
                touchModes[touch] = .dragging
            }
        }
    }
    
    public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView?) {
        guard let view else { return }
        let dragTouches = touches.filter { touchModes[$0] == .dragging }
        let resizeTouches = touches.filter { touchModes[$0] == .resizing }
        for t in dragTouches { handleDragMove(t, in: view) }
        for t in resizeTouches { handleResizeMove(t, in: view) }
    }
    
    public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        cleanupTouches(touches)
        activeLineIDs.removeAll()
    }
    
    public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}

// MARK: - 드래그 & 리사이즈/회전/그리드

private extension DragManager {
    // ────── 한 손 드래그 ──────
    func handleDragMove(_ touch: UITouch, in view: UIView) {
        guard let item = draggingItems[touch],
              let idx = items.firstIndex(where: { $0.id == item.id })
        else { return }
        
        let loc = touch.location(in: view)
        let prev = touch.previousLocation(in: view)
        let dX = loc.x - prev.x
        let dY = loc.y - prev.y
        
        var rect = items[idx].rect
        rect.origin.x += dX
        rect.origin.y += dY
        rect.origin.x = max(0, min(rect.origin.x, view.bounds.width - rect.width))
        rect.origin.y = max(0, min(rect.origin.y, view.bounds.height - rect.height))
        items[idx].rect = rect
        
        applyGridEffect(on: idx, in: view)
    }
    
    // ────── 두 손 리사이즈 + 회전 ──────
    func handleResizeMove(_ touch: UITouch, in view: UIView) {
        guard let item = resizingItems[touch],
              let initSize = initialSizes[touch],
              let initRot = initialRotations[touch],
              let anchor = anchorTouches[touch],
              let ratio = anchorRatios[touch],
              let initDist = initialAnchorDistances[touch],
              let startAngle = startAngles[touch],
              let idx = items.firstIndex(where: { $0.id == item.id })
        else { return }
        
        let anchorPt = anchor.location(in: view)
        let curPt = touch.location(in: view)
        
        // 스케일
        let curDist = hypot(curPt.x - anchorPt.x, curPt.y - anchorPt.y)
        let scale = max(0.3, min(curDist / initDist, 3.0))
        let newW = initSize.width * scale
        let newH = initSize.height * scale
        
        // 회전 계산
        let curAngle = atan2(curPt.y - anchorPt.y, curPt.x - anchorPt.x)
        var deltaRad = curAngle - startAngle
        
        // 각도 정규화 (-π ~ π)
        while deltaRad > .pi { deltaRad -= 2 * .pi }
        while deltaRad < -.pi { deltaRad += 2 * .pi }
        
        // 회전 임계값 체크
        let threshold = rotateThresholdDeg * .pi / 180
        let newRotationRad: CGFloat
        
        if abs(deltaRad) > threshold {
            // 새로운 누적 회전각도 계산
            let candidateRotation = initRot + deltaRad
            
            // 스냅 각도 체크 (0°, 90°, 180°, 270°, 360°)
            let candidateRotationDeg = candidateRotation * 180 / .pi
            let normalizedDeg = candidateRotationDeg.truncatingRemainder(dividingBy: 360)
            let adjustedDeg = normalizedDeg < 0 ? normalizedDeg + 360 : normalizedDeg
            
            // 가장 가까운 스냅 각도 찾기
            var snappedDeg: CGFloat?
            for snapAngle in rotationSnapAngles {
                let distance = min(
                    abs(adjustedDeg - snapAngle),
                    abs(adjustedDeg - snapAngle - 360),
                    abs(adjustedDeg - snapAngle + 360)
                )
                if distance <= rotationSnapThreshold {
                    // 원본 기준으로 스냅 각도 계산
                    let fullRotations = floor(candidateRotationDeg / 360)
                    snappedDeg = fullRotations * 360 + snapAngle
                    break
                }
            }
            
            if let snapped = snappedDeg {
                newRotationRad = snapped * .pi / 180
            } else {
                newRotationRad = candidateRotation
            }
        } else {
            newRotationRad = initRot
        }
        
        // 앵커 고정 origin
        var origin = CGPoint(
            x: anchorPt.x - ratio.x * newW,
            y: anchorPt.y - ratio.y * newH
        )
        origin.x = max(0, min(origin.x, view.bounds.width - newW))
        origin.y = max(0, min(origin.y, view.bounds.height - newH))
        
        items[idx].rect = CGRect(origin: origin, size: CGSize(width: newW, height: newH))
        items[idx].originalRotation = newRotationRad
        items[idx].rotation = .radians(newRotationRad)
        
        applyGridEffect(on: idx, in: view)
    }
    
    // ────── 그리드: 모서리만, 부드러운 스냅 ──────
    func applyGridEffect(on idx: Int, in view: UIView) {
        guard idx < items.count else { return }
        var rect = items[idx].rect
        activeLineIDs.removeAll()
        
        // 모서리 두 점
        let xEdges = [rect.minX, rect.maxX]
        let yEdges = [rect.minY, rect.maxY]
        
        // 세로 라인
        for line in gridLines where line.orientation == .vertical {
            if let best = xEdges
                .map({ ($0, abs($0 - line.position)) })
                .min(by: { $0.1 < $1.1 }) {
                
                let edge = best.0
                let dist = best.1
                
                if dist < activateThreshold { activeLineIDs.insert(line.id) }
                
                if dist < stickyThreshold, dist > snapThreshold {
                    let move = (snapThreshold / stickyThreshold) * (line.position - edge)
                    rect.origin.x += move
                }
                if dist <= snapThreshold {
                    rect.origin.x += line.position - edge
                }
            }
        }
        // 가로 라인
        for line in gridLines where line.orientation == .horizontal {
            if let best = yEdges
                .map({ ($0, abs($0 - line.position)) })
                .min(by: { $0.1 < $1.1 }) {
                
                let edge = best.0
                let dist = best.1
                
                if dist < activateThreshold { activeLineIDs.insert(line.id) }
                
                if dist < stickyThreshold, dist > snapThreshold {
                    let move = (snapThreshold / stickyThreshold) * (line.position - edge)
                    rect.origin.y += move
                }
                if dist <= snapThreshold {
                    rect.origin.y += line.position - edge
                }
            }
        }
        
        // 경계 보정
        rect.origin.x = max(0, min(rect.origin.x, view.bounds.width - rect.width))
        rect.origin.y = max(0, min(rect.origin.y, view.bounds.height - rect.height))
        items[idx].rect = rect
    }
    
    // ────── 터치 정리 ──────
    func cleanupTouches(_ touches: Set<UITouch>) {
        // 기본 정리
        for t in touches {
            draggingItems.removeValue(forKey: t)
            initialPositions.removeValue(forKey: t)
            resizingItems.removeValue(forKey: t)
            initialSizes.removeValue(forKey: t)
            initialRotations.removeValue(forKey: t)
            anchorTouches.removeValue(forKey: t)
            anchorRatios.removeValue(forKey: t)
            initialAnchorDistances.removeValue(forKey: t)
            startAngles.removeValue(forKey: t)
            touchModes.removeValue(forKey: t)
        }
        
        // 앵커가 떨어지면 해당 세션 종료
        for ended in touches {
            let victims = anchorTouches.filter { $0.value == ended }.map(\.key)
            for v in victims {
                resizingItems.removeValue(forKey: v)
                initialSizes.removeValue(forKey: v)
                initialRotations.removeValue(forKey: v)
                anchorTouches.removeValue(forKey: v)
                anchorRatios.removeValue(forKey: v)
                initialAnchorDistances.removeValue(forKey: v)
                startAngles.removeValue(forKey: v)
                touchModes.removeValue(forKey: v)
            }
        }
    }
}

// MARK: - 그리드 오버레이

public struct GridOverlay: View {
    public let lines: [GridLine]
    public let activeLineIDs: Set<UUID>
    
    public init(lines: [GridLine], activeLineIDs: Set<UUID>) {
        self.lines = lines
        self.activeLineIDs = activeLineIDs
    }
    
    public var body: some View {
        GeometryReader { geo in
            ForEach(lines) { line in
                if line.orientation == .vertical {
                    Rectangle()
                        .frame(width: 1, height: geo.size.height)
                        .position(x: line.position, y: geo.size.height / 2)
                        .foregroundColor(activeLineIDs.contains(line.id) ? .orange : .gray.opacity(0.3))
                } else {
                    Rectangle()
                        .frame(width: geo.size.width, height: 1)
                        .position(x: geo.size.width / 2, y: line.position)
                        .foregroundColor(activeLineIDs.contains(line.id) ? .orange : .gray.opacity(0.3))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - 드래그 가능한 뷰

public struct DraggableView: View {
    @State private var dragManager: DragManager
    public let itemColors: [Color]
    public let showInfo: Bool
    
    public init(
        items: [DraggableItem] = [],
        gridLines: [GridLine] = [],
        itemColors: [Color] = [.red, .green, .blue, .orange, .purple],
        showInfo: Bool = true
    ) {
        self._dragManager = State(initialValue: DragManager(items: items, gridLines: gridLines))
        self.itemColors = itemColors
        self.showInfo = showInfo
    }
    
    public var body: some View {
        ZStack {
            // 멀티터치 감지 레이어
            MultiTouchView(delegate: dragManager)
            
            // 드래그 가능한 아이템들
            ForEach(Array(dragManager.items.enumerated()), id: \.element.id) { index, item in
                RoundedRectangle(cornerRadius: 12)
                    .fill(itemColor(index))
                    .frame(width: item.rect.width, height: item.rect.height)
                    .rotationEffect(item.rotation)
                    .position(x: item.rect.midX, y: item.rect.midY)
                    .allowsHitTesting(false)
                    .overlay(
                        VStack(spacing: 4) {
                            Text("\(index + 1)")
                                .bold()
                                .foregroundColor(.white)
                            Text("\(Int(item.rect.width))×\(Int(item.rect.height))")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(Int(item.rotation.degrees))°")
                                .font(.caption2)
                                .foregroundColor(.yellow.opacity(0.8))
                        }
                        .rotationEffect(-item.rotation)
                    )
            }
            
            // 그리드 오버레이
            GridOverlay(lines: dragManager.gridLines, activeLineIDs: dragManager.activeLineIDs)
            
            // 상태 정보 (옵션)
            if showInfo {
                statusOverlay
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func itemColor(_ index: Int) -> Color {
        itemColors[index % itemColors.count]
    }
    
    private var statusOverlay: some View {
        VStack {
            HStack(spacing: 12) {
                if dragManager.isDraggingActive {
                    statusBadge("🖐️ 드래그 중", .blue)
                }
                if dragManager.isResizingActive {
                    statusBadge("↕️ 크기·회전 중", .orange)
                }
                if dragManager.isGridActive {
                    statusBadge("📐 그리드", .green)
                }
            }
            .padding(.top, 50)
            Spacer()
        }
    }
    
    private func statusBadge(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.caption)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .cornerRadius(20)
    }
}


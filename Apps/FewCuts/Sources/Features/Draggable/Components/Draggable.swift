//
//  Draggable.swift
//  FewCuts
//
//  Created by 송영모 on 6/13/25.
//

import Foundation
import SwiftUI

public protocol Draggable: Identifiable {
    associatedtype Content: View
    
    var id: DraggableID { get }
    var rect: CGRect { get set }
    var rotation: Angle { get set }
    var originalRotation: CGFloat { get set }
    
    @ViewBuilder
    func createView(index: Int, color: Color) -> Content
    
    // 사이즈/회전 변경 인터셉터 - 각 타입이 자신만의 로직으로 처리 가능
    func interceptSizeChange(newRect: CGRect) -> CGRect
    func interceptRotationChange(newRotation: Angle, newOriginalRotation: CGFloat) -> (Angle, CGFloat)
}

public struct DraggableID: Hashable, Identifiable {
    public let id: UUID
    
    public init() {
        self.id = UUID()
    }
    
    public init(id: UUID) {
        self.id = id
    }
}

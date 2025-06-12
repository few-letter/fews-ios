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

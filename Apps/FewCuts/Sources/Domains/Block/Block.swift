//
//  Block.swift
//  FewCuts
//
//  Created by 송영모 on 6/9/25.
//

import Foundation

public struct BlockID: Hashable, Identifiable {
    public let id: UUID
    
    public init() {
        self.id = UUID()
    }
    
    public init(id: UUID) {
        self.id = id
    }
}

public protocol Block {
    var id: BlockID { get }
    var rect: CGRect { get set }
}

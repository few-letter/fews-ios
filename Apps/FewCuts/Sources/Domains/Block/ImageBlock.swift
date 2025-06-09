//
//  ImageBlock.swift
//  FewCuts
//
//  Created by 송영모 on 6/9/25.
//

import Foundation

@Observable
public class ImageBlock: Block, Identifiable {
    public var id: BlockID = .init()
    public var rect: CGRect
    public var rotation: Double = 0
    
    public init(rect: CGRect) {
        self.rect = rect
    }
}

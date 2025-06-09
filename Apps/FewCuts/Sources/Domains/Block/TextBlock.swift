//
//  TextBlock.swift
//  FewCuts
//
//  Created by 송영모 on 6/9/25.
//

import Foundation

@Observable
public class TextBlock: Block, Identifiable {
    public var id: BlockID = .init()
    public var rect: CGRect
    public var text: String
    public var rotation: Double = 0
    
    public init(rect: CGRect, text: String) {
        self.rect = rect
        self.text = text
    }
}

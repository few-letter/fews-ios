//
//  Layer.swift
//  FewCuts
//
//  Created by 송영모 on 6/9/25.
//

import SwiftUI

@Observable
public class Layer {
    public var color: Color
    public var size: CGSize
    
    public init(color: Color, size: CGSize) {
        self.color = color
        self.size = size
    }
}

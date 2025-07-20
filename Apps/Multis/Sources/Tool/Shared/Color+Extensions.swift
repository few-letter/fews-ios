//
//  Color+Extensions.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import SwiftUI

extension Color {
    public init?(hex: String) {
        let r, g, b: Double
        
        let hexColor = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        
        guard hexColor.count == 6 else {
            return nil
        }
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            r = Double((hexNumber & 0xff0000) >> 16) / 255
            g = Double((hexNumber & 0x00ff00) >> 8) / 255
            b = Double(hexNumber & 0x0000ff) / 255
            
            self.init(red: r, green: g, blue: b)
            return
        }
        
        return nil
    }
}

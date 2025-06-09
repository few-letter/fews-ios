//
//  ToolButton.swift
//  FewCuts
//
//  Created by 송영모 on 6/9/25.
//

import SwiftUI

public struct ToolButton: View {
    public let systemImageName: String
    public let action: () -> Void
    
    public init(systemImageName: String, action: @escaping () -> Void) {
        self.systemImageName = systemImageName
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Circle()
                .fill(.gray)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: systemImageName)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
        }
    }
}

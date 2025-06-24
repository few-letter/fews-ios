//
//  AddTagStore.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import ComposableArchitecture
import Foundation
import SwiftData
import SwiftUI

@Reducer
public struct AddTagStore {
    @ObservableState
    public struct State {
        var tag: Tag = Tag(
            id: UUID(),
            hex: "#007AFF",
            name: ""
        )
        
        var selectedColor: Color {
            get { Color(hex: tag.hex) ?? .blue }
            set { tag.hex = newValue.toHexString() }
        }
        
        var isFormValid: Bool {
            !tag.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !tag.hex.isEmpty &&
            isValidHexColor(tag.hex)
        }
        
        private func isValidHexColor(_ hex: String) -> Bool {
            let pattern = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
            let regex = try? NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: hex.utf16.count)
            return regex?.firstMatch(in: hex, options: [], range: range) != nil
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case colorChanged(Color)
        case saveButtonTapped
        case cancelButtonTapped
        case tagSaved
    }
    
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case let .colorChanged(color):
                state.selectedColor = color
                return .none
                
            case .saveButtonTapped:
                guard state.isFormValid else { return .none }
                
                return .run { [tag = state.tag] send in
                    // Tag 모델을 그대로 사용
                    // Save to SwiftData context
                    // This would typically be handled by a repository
                    
                    await send(.tagSaved)
                }
                
            case .cancelButtonTapped:
                return .run { _ in await dismiss() }
                
            case .tagSaved:
                return .run { _ in await dismiss() }
            }
        }
    }
}

// MARK: - Color Extensions
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHexString() -> String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

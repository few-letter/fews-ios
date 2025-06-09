import SwiftUI

public struct HeroButton: View {
    private let text: String
    private let action: () -> Void
    private let variant: HeroToken.Components.Button.Variant
    private let size: HeroToken.Components.Button.Size
    private let buttonColorScheme: HeroToken.Components.Button.ColorScheme
    private let isDisabled: Bool
    private let isLoading: Bool
    private let startIcon: Image?
    private let endIcon: Image?
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    public init(
        _ text: String,
        variant: HeroToken.Components.Button.Variant = .solid,
        size: HeroToken.Components.Button.Size = .md,
        buttonColorScheme: HeroToken.Components.Button.ColorScheme = .primary,
        isDisabled: Bool = false,
        isLoading: Bool = false,
        startIcon: Image? = nil,
        endIcon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.variant = variant
        self.size = size
        self.buttonColorScheme = buttonColorScheme
        self.isDisabled = isDisabled
        self.isLoading = isLoading
        self.startIcon = startIcon
        self.endIcon = endIcon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: HeroToken.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                } else {
                    if let startIcon = startIcon {
                        startIcon
                            .font(.system(size: iconSize))
                    }
                    
                    Text(text)
                        .font(size.font)
                        .lineLimit(1)
                    
                    if let endIcon = endIcon {
                        endIcon
                            .font(.system(size: iconSize))
                    }
                }
            }
            .padding(size.padding)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isDisabled ? HeroToken.Opacity._50 : 1.0)
            .animation(HeroToken.Animation.fast, value: isPressed)
            .animation(HeroToken.Animation.fast, value: isHovered)
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .solid:
            return isHovered ? buttonColorScheme.backgroundColor.opacity(0.9) : buttonColorScheme.backgroundColor
        case .bordered:
            return isHovered ? buttonColorScheme.backgroundColor.opacity(0.1) : Color.clear
        case .light:
            return isHovered ? buttonColorScheme.backgroundColor.opacity(0.2) : buttonColorScheme.backgroundColor.opacity(0.1)
        case .flat:
            return isHovered ? buttonColorScheme.backgroundColor.opacity(0.2) : buttonColorScheme.backgroundColor.opacity(0.15)
        case .faded:
            return isHovered ? HeroToken.Colors.surface.opacity(0.8) : HeroToken.Colors.surface
        case .shadow:
            return isHovered ? buttonColorScheme.backgroundColor.opacity(0.9) : buttonColorScheme.backgroundColor
        case .ghost:
            return isHovered ? buttonColorScheme.backgroundColor.opacity(0.1) : Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch variant {
        case .solid, .shadow:
            return buttonColorScheme.foregroundColor
        case .bordered, .light, .flat, .faded, .ghost:
            return buttonColorScheme.backgroundColor
        }
    }
    
    private var borderColor: Color {
        switch variant {
        case .bordered:
            return buttonColorScheme.backgroundColor
        default:
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch variant {
        case .bordered:
            return 1
        default:
            return 0
        }
    }
    
    private var cornerRadius: CGFloat {
        switch size {
        case .sm:
            return HeroToken.Radius.sm
        case .md:
            return HeroToken.Radius.md
        case .lg:
            return HeroToken.Radius.lg
        }
    }
    
    private var iconSize: CGFloat {
        switch size {
        case .sm:
            return 14
        case .md:
            return 16
        case .lg:
            return 18
        }
    }
}

public extension HeroButton {
    static func primary(_ title: String, action: @escaping () -> Void) -> HeroButton {
        HeroButton(title, buttonColorScheme: .primary, action: action)
    }
    
    static func secondary(_ title: String, action: @escaping () -> Void) -> HeroButton {
        HeroButton(title, variant: .bordered, buttonColorScheme: .primary, action: action)
    }
    
    static func success(_ title: String, action: @escaping () -> Void) -> HeroButton {
        HeroButton(title, buttonColorScheme: .success, action: action)
    }
    
    static func warning(_ title: String, action: @escaping () -> Void) -> HeroButton {
        HeroButton(title, buttonColorScheme: .warning, action: action)
    }
    
    static func danger(_ title: String, action: @escaping () -> Void) -> HeroButton {
        HeroButton(title, buttonColorScheme: .danger, action: action)
    }
} 
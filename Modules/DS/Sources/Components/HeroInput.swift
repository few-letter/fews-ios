import SwiftUI

public struct HeroInput: View {
    @Binding private var text: String
    private let placeholder: String
    private let variant: HeroToken.Components.Input.Variant
    private let size: HeroToken.Components.Input.Size
    private let isDisabled: Bool
    private let isReadOnly: Bool
    private let startIcon: Image?
    private let endIcon: Image?
    
    @State private var isFocused = false
    
    public init(
        text: Binding<String>,
        placeholder: String = "",
        variant: HeroToken.Components.Input.Variant = .bordered,
        size: HeroToken.Components.Input.Size = .md,
        isDisabled: Bool = false,
        isReadOnly: Bool = false,
        startIcon: Image? = nil,
        endIcon: Image? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.variant = variant
        self.size = size
        self.isDisabled = isDisabled
        self.isReadOnly = isReadOnly
        self.startIcon = startIcon
        self.endIcon = endIcon
    }
    
    public var body: some View {
        HStack(spacing: HeroToken.Spacing.sm) {
            if let startIcon = startIcon {
                startIcon
                    .font(.system(size: iconSize))
                    .foregroundColor(iconColor)
            }
            
            TextField(placeholder, text: $text)
                .font(size.font)
                .disabled(isDisabled || isReadOnly)
                .onTapGesture {
                    isFocused = true
                }
            
            if let endIcon = endIcon {
                endIcon
                    .font(.system(size: iconSize))
                    .foregroundColor(iconColor)
            }
        }
        .padding(size.padding)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .opacity(isDisabled ? HeroToken.Opacity._60 : 1.0)
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .flat:
            return HeroToken.Colors.Default._100
        case .bordered:
            return HeroToken.Colors.surface
        case .underlined:
            return Color.clear
        case .faded:
            return HeroToken.Colors.Default._50
        }
    }
    
    private var borderColor: Color {
        switch variant {
        case .bordered:
            return isFocused ? HeroToken.Colors.focus : HeroToken.Colors.divider
        case .underlined:
            return isFocused ? HeroToken.Colors.focus : HeroToken.Colors.divider
        default:
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch variant {
        case .bordered, .underlined:
            return isFocused ? 2 : 1
        default:
            return 0
        }
    }
    
    private var cornerRadius: CGFloat {
        switch variant {
        case .underlined:
            return 0
        default:
            return HeroToken.Radius.md
        }
    }
    
    private var iconColor: Color {
        isDisabled ? HeroToken.Colors.content4 : HeroToken.Colors.content3
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
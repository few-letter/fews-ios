import SwiftUI

public struct HeroCard<Content: View>: View {
    private let content: Content
    private let cardShadow: HeroToken.Components.Card.Shadow
    private let radius: CGFloat
    private let isHoverable: Bool
    private let isPressable: Bool
    private let isBlurred: Bool
    private let onPress: (() -> Void)?
    
    @State private var isHovered = false
    @State private var isPressed = false
    
    public init(
        cardShadow: HeroToken.Components.Card.Shadow = .md,
        radius: CGFloat = HeroToken.Radius.lg,
        isHoverable: Bool = false,
        isPressable: Bool = false,
        isBlurred: Bool = false,
        onPress: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.cardShadow = cardShadow
        self.radius = radius
        self.isHoverable = isHoverable
        self.isPressable = isPressable
        self.isBlurred = isBlurred
        self.onPress = onPress
        self.content = content()
    }
    
    public var body: some View {
        Group {
            if isPressable {
                Button(action: { onPress?() }) {
                    cardContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                cardContent
            }
        }
        .onHover { hovering in
            if isHoverable || isPressable {
                withAnimation(HeroToken.Animation.fast) {
                    isHovered = hovering
                }
            }
        }
        .pressEvents {
            if isPressable {
                withAnimation(HeroToken.Animation.fast) {
                    isPressed = true
                }
            }
        } onRelease: {
            if isPressable {
                withAnimation(HeroToken.Animation.fast) {
                    isPressed = false
                }
            }
        }
    }
    
    private var cardContent: some View {
        content
            .background(cardBackground)
            .cornerRadius(radius)
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: shadowOffset.width,
                y: shadowOffset.height
            )
            .scaleEffect(transformScale)
            .animation(HeroToken.Animation.spring, value: isHovered)
            .animation(HeroToken.Animation.fast, value: isPressed)
    }
    
    private var cardBackground: some View {
        Group {
            if isBlurred {
                Color.clear
                    .background(.ultraThinMaterial)
            } else {
                HeroToken.Colors.surface
            }
        }
    }
    
    private var shadowColor: Color {
        Color.black.opacity(cardShadow.style.opacity)
    }
    
    private var shadowRadius: CGFloat {
        let baseRadius = cardShadow.style.radius
        if isHovered && isHoverable {
            return baseRadius * 1.5
        }
        return baseRadius
    }
    
    private var shadowOffset: CGSize {
        let baseOffset = cardShadow.style.offset
        if isHovered && isHoverable {
            return CGSize(width: baseOffset.width, height: baseOffset.height * 1.2)
        }
        return baseOffset
    }
    
    private var transformScale: CGFloat {
        if isPressed {
            return 0.98
        } else if isHovered && (isHoverable || isPressable) {
            return 1.02
        }
        return 1.0
    }
}

public struct HeroCardHeader<Content: View>: View {
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
                .padding(.horizontal, HeroToken.Spacing.md)
                .padding(.top, HeroToken.Spacing.md)
        }
    }
}

public struct HeroCardBody<Content: View>: View {
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
                .padding(.horizontal, HeroToken.Spacing.md)
                .padding(.vertical, HeroToken.Spacing.sm)
        }
    }
}

public struct HeroCardFooter<Content: View>: View {
    private let content: Content
    private let isBlurred: Bool
    
    public init(isBlurred: Bool = false, @ViewBuilder content: () -> Content) {
        self.isBlurred = isBlurred
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
                .padding(.horizontal, HeroToken.Spacing.md)
                .padding(.bottom, HeroToken.Spacing.md)
        }
        .background(
            Group {
                if isBlurred {
                    Color.clear
                        .background(.ultraThinMaterial)
                } else {
                    Color.clear
                }
            }
        )
    }
} 
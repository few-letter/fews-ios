import SwiftUI

public struct Hero {
    public init() {}
}

public struct HeroToken {
    public init() {}
}

// MARK: - Colors System (HeroUI 기반)
public extension HeroToken {
    enum Colors {
        // MARK: - Semantic Colors (HeroUI 기반)
        public static let primary = Color.blue
        public static let secondary = Color.gray
        public static let success = Color.green
        public static let warning = Color.orange
        public static let danger = Color.red
        
        // MARK: - Layout Colors
        public static let background = Color(red: 1.0, green: 1.0, blue: 1.0)
        public static let foreground = Color(red: 0.0, green: 0.0, blue: 0.0)
        public static let surface = Color(red: 0.98, green: 0.98, blue: 0.98)
        public static let divider = Color(red: 0.9, green: 0.9, blue: 0.9)
        public static let focus = Color.blue.opacity(0.5)
        
        // MARK: - Content Colors
        public static let content1 = Color(red: 0.0, green: 0.0, blue: 0.0)
        public static let content2 = Color(red: 0.3, green: 0.3, blue: 0.3)
        public static let content3 = Color(red: 0.5, green: 0.5, blue: 0.5)
        public static let content4 = Color(red: 0.7, green: 0.7, blue: 0.7)
        
        // MARK: - Default Palette
        public enum Default {
            public static let _50 = Color(red: 0.98, green: 0.98, blue: 0.98)
            public static let _100 = Color(red: 0.95, green: 0.95, blue: 0.95)
            public static let _200 = Color(red: 0.88, green: 0.88, blue: 0.88)
            public static let _300 = Color(red: 0.82, green: 0.82, blue: 0.82)
            public static let _400 = Color(red: 0.63, green: 0.63, blue: 0.63)
            public static let _500 = Color(red: 0.44, green: 0.44, blue: 0.44)
            public static let _600 = Color(red: 0.33, green: 0.33, blue: 0.33)
            public static let _700 = Color(red: 0.25, green: 0.25, blue: 0.25)
            public static let _800 = Color(red: 0.15, green: 0.15, blue: 0.15)
            public static let _900 = Color(red: 0.09, green: 0.09, blue: 0.09)
        }
        
        // MARK: - Blue Palette (Primary)
        public enum Blue {
            public static let _50 = Color(red: 0.94, green: 0.97, blue: 1.0)
            public static let _100 = Color(red: 0.88, green: 0.94, blue: 1.0)
            public static let _200 = Color(red: 0.76, green: 0.87, blue: 1.0)
            public static let _300 = Color(red: 0.58, green: 0.78, blue: 1.0)
            public static let _400 = Color(red: 0.38, green: 0.68, blue: 1.0)
            public static let _500 = Color(red: 0.0, green: 0.55, blue: 1.0) // primary
            public static let _600 = Color(red: 0.0, green: 0.44, blue: 0.8)
            public static let _700 = Color(red: 0.0, green: 0.33, blue: 0.6)
            public static let _800 = Color(red: 0.0, green: 0.22, blue: 0.4)
            public static let _900 = Color(red: 0.0, green: 0.11, blue: 0.2)
        }
        
        // MARK: - Green Palette (Success)
        public enum Green {
            public static let _50 = Color(red: 0.94, green: 0.99, blue: 0.95)
            public static let _100 = Color(red: 0.86, green: 0.98, blue: 0.89)
            public static let _200 = Color(red: 0.68, green: 0.95, blue: 0.76)
            public static let _300 = Color(red: 0.44, green: 0.89, blue: 0.58)
            public static let _400 = Color(red: 0.22, green: 0.83, blue: 0.41)
            public static let _500 = Color(red: 0.0, green: 0.75, blue: 0.22) // success
            public static let _600 = Color(red: 0.0, green: 0.6, blue: 0.18)
            public static let _700 = Color(red: 0.0, green: 0.45, blue: 0.13)
            public static let _800 = Color(red: 0.0, green: 0.3, blue: 0.09)
            public static let _900 = Color(red: 0.0, green: 0.15, blue: 0.04)
        }
        
        // MARK: - Orange Palette (Warning)
        public enum Orange {
            public static let _50 = Color(red: 1.0, green: 0.98, blue: 0.94)
            public static let _100 = Color(red: 1.0, green: 0.95, blue: 0.86)
            public static let _200 = Color(red: 1.0, green: 0.89, blue: 0.68)
            public static let _300 = Color(red: 1.0, green: 0.81, blue: 0.44)
            public static let _400 = Color(red: 1.0, green: 0.72, blue: 0.22)
            public static let _500 = Color(red: 1.0, green: 0.6, blue: 0.0) // warning
            public static let _600 = Color(red: 0.8, green: 0.48, blue: 0.0)
            public static let _700 = Color(red: 0.6, green: 0.36, blue: 0.0)
            public static let _800 = Color(red: 0.4, green: 0.24, blue: 0.0)
            public static let _900 = Color(red: 0.2, green: 0.12, blue: 0.0)
        }
        
        // MARK: - Red Palette (Danger)
        public enum Red {
            public static let _50 = Color(red: 1.0, green: 0.94, blue: 0.94)
            public static let _100 = Color(red: 1.0, green: 0.86, blue: 0.86)
            public static let _200 = Color(red: 1.0, green: 0.68, blue: 0.68)
            public static let _300 = Color(red: 1.0, green: 0.44, blue: 0.44)
            public static let _400 = Color(red: 1.0, green: 0.22, blue: 0.22)
            public static let _500 = Color(red: 0.95, green: 0.0, blue: 0.0) // danger
            public static let _600 = Color(red: 0.76, green: 0.0, blue: 0.0)
            public static let _700 = Color(red: 0.57, green: 0.0, blue: 0.0)
            public static let _800 = Color(red: 0.38, green: 0.0, blue: 0.0)
            public static let _900 = Color(red: 0.19, green: 0.0, blue: 0.0)
        }
        
        // MARK: - Purple Palette
        public enum Purple {
            public static let _50 = Color(red: 0.95, green: 0.91, blue: 0.98)
            public static let _100 = Color(red: 0.89, green: 0.83, blue: 0.96)
            public static let _200 = Color(red: 0.79, green: 0.66, blue: 0.91)
            public static let _300 = Color(red: 0.68, green: 0.49, blue: 0.87)
            public static let _400 = Color(red: 0.58, green: 0.33, blue: 0.83)
            public static let _500 = Color(red: 0.47, green: 0.16, blue: 0.78)
            public static let _600 = Color(red: 0.38, green: 0.13, blue: 0.63)
            public static let _700 = Color(red: 0.28, green: 0.09, blue: 0.47)
            public static let _800 = Color(red: 0.19, green: 0.06, blue: 0.31)
            public static let _900 = Color(red: 0.09, green: 0.03, blue: 0.16)
        }
    }
}

// MARK: - Typography System (HeroUI 기반)
public extension HeroToken {
    enum Typography {
        public static let largeTitle = Font.largeTitle
        public static let title1 = Font.title
        public static let title2 = Font.title2
        public static let title3 = Font.title3
        public static let headline = Font.headline
        public static let subheadline = Font.subheadline
        public static let body = Font.body
        public static let callout = Font.callout
        public static let footnote = Font.footnote
        public static let caption1 = Font.caption
        public static let caption2 = Font.caption2
        
        public static let ultraLight = Font.Weight.ultraLight
        public static let thin = Font.Weight.thin
        public static let light = Font.Weight.light
        public static let regular = Font.Weight.regular
        public static let medium = Font.Weight.medium
        public static let semibold = Font.Weight.semibold
        public static let bold = Font.Weight.bold
        public static let heavy = Font.Weight.heavy
        public static let black = Font.Weight.black
        
        public static let h1 = Font.largeTitle.weight(.bold)
        public static let h2 = Font.title.weight(.bold)
        public static let h3 = Font.title2.weight(.semibold)
        public static let h4 = Font.title3.weight(.semibold)
        public static let h5 = Font.headline.weight(.medium)
        public static let h6 = Font.subheadline.weight(.medium)
        public static let bodyRegular = Font.body.weight(.regular)
        public static let bodyMedium = Font.body.weight(.medium)
        public static let bodyBold = Font.body.weight(.bold)
        public static let smallRegular = Font.footnote.weight(.regular)
        public static let smallMedium = Font.footnote.weight(.medium)
    }
}

// MARK: - Spacing System (HeroUI 기반)
public extension HeroToken {
    enum Spacing {
        public static let none: CGFloat = 0
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let xxl: CGFloat = 48
        public static let xxxl: CGFloat = 64
        
        public static let _1: CGFloat = 4
        public static let _2: CGFloat = 8
        public static let _3: CGFloat = 12
        public static let _4: CGFloat = 16
        public static let _5: CGFloat = 20
        public static let _6: CGFloat = 24
        public static let _7: CGFloat = 28
        public static let _8: CGFloat = 32
        public static let _9: CGFloat = 36
        public static let _10: CGFloat = 40
        public static let _12: CGFloat = 48
        public static let _16: CGFloat = 64
        public static let _20: CGFloat = 80
        public static let _24: CGFloat = 96
        public static let _32: CGFloat = 128
    }
}

// MARK: - Radius System (HeroUI 기반)
public extension HeroToken {
    enum Radius {
        public static let none: CGFloat = 0
        public static let sm: CGFloat = 4
        public static let md: CGFloat = 8
        public static let lg: CGFloat = 12
        public static let xl: CGFloat = 16
        public static let xxl: CGFloat = 24
        public static let full: CGFloat = 9999
    }
}

// MARK: - Shadow System (HeroUI 기반)
public extension HeroToken {
    enum Shadow {
        public static let none = HeroShadowStyle.none
        public static let sm = HeroShadowStyle.sm
        public static let md = HeroShadowStyle.md
        public static let lg = HeroShadowStyle.lg
        public static let xl = HeroShadowStyle.xl
    }
    
    enum ShadowStyle {
        case none, sm, md, lg, xl
        
        var radius: CGFloat {
            switch self {
            case .none: return 0
            case .sm: return 2
            case .md: return 4
            case .lg: return 8
            case .xl: return 16
            }
        }
        
        var offset: CGSize {
            switch self {
            case .none: return .zero
            case .sm: return CGSize(width: 0, height: 1)
            case .md: return CGSize(width: 0, height: 2)
            case .lg: return CGSize(width: 0, height: 4)
            case .xl: return CGSize(width: 0, height: 8)
            }
        }
        
        var opacity: Double {
            switch self {
            case .none: return 0
            case .sm: return 0.1
            case .md: return 0.15
            case .lg: return 0.2
            case .xl: return 0.25
            }
        }
    }
}

public typealias HeroShadowStyle = HeroToken.ShadowStyle

// MARK: - Animation System
public extension HeroToken {
    enum Animation {
        public static let fast = SwiftUI.Animation.easeInOut(duration: 0.15)
        public static let normal = SwiftUI.Animation.easeInOut(duration: 0.25)
        public static let slow = SwiftUI.Animation.easeInOut(duration: 0.35)
        public static let spring = SwiftUI.Animation.spring(duration: 0.25)
        public static let bouncy = SwiftUI.Animation.bouncy
    }
}

// MARK: - Opacity System
public extension HeroToken {
    enum Opacity {
        public static let none: Double = 0
        public static let low: Double = 0.1
        public static let medium: Double = 0.5
        public static let high: Double = 0.8
        public static let full: Double = 1.0
        
        public static let _10: Double = 0.1
        public static let _20: Double = 0.2
        public static let _30: Double = 0.3
        public static let _40: Double = 0.4
        public static let _50: Double = 0.5
        public static let _60: Double = 0.6
        public static let _70: Double = 0.7
        public static let _80: Double = 0.8
        public static let _90: Double = 0.9
    }
}

// MARK: - Component Styles
public extension HeroToken {
    enum Components {
        public enum Button {
            public enum Variant {
                case solid, bordered, light, flat, faded, shadow, ghost
            }
            
            public enum Size {
                case sm, md, lg
                
                var padding: EdgeInsets {
                    switch self {
                    case .sm: return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
                    case .md: return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
                    case .lg: return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
                    }
                }
                
                var font: Font {
                    switch self {
                    case .sm: return .footnote.weight(.medium)
                    case .md: return .body.weight(.medium)
                    case .lg: return .headline.weight(.medium)
                    }
                }
            }
            
            public enum ColorScheme {
                case `default`, primary, secondary, success, warning, danger
                
                var backgroundColor: Color {
                    switch self {
                    case .default: return HeroToken.Colors.Default._500
                    case .primary: return HeroToken.Colors.Blue._500
                    case .secondary: return HeroToken.Colors.Purple._500
                    case .success: return HeroToken.Colors.Green._500
                    case .warning: return HeroToken.Colors.Orange._500
                    case .danger: return HeroToken.Colors.Red._500
                    }
                }
                
                var foregroundColor: Color {
                    return .white
                }
            }
        }
        
        public enum Card {
            public enum Shadow {
                case none, sm, md, lg
                
                var style: HeroToken.ShadowStyle {
                    switch self {
                    case .none: return .none
                    case .sm: return .sm
                    case .md: return .md
                    case .lg: return .lg
                    }
                }
            }
        }
        
        public enum Input {
            public enum Variant {
                case flat, bordered, underlined, faded
            }
            
            public enum Size {
                case sm, md, lg
                
                var padding: EdgeInsets {
                    switch self {
                    case .sm: return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
                    case .md: return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
                    case .lg: return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
                    }
                }
                
                var font: Font {
                    switch self {
                    case .sm: return .footnote
                    case .md: return .body
                    case .lg: return .headline
                    }
                }
            }
        }
    }
}

// MARK: - Layout Constants
public extension HeroToken {
    enum Layout {
        public static let maxContentWidth: CGFloat = 1200
        public static let sidebarWidth: CGFloat = 280
        public static let navbarHeight: CGFloat = 64
        public static let tabbarHeight: CGFloat = 80
        public static let minimumTouchTarget: CGFloat = 44
    }
}

// MARK: - Breakpoints (for responsive design)
public extension HeroToken {
    enum Breakpoint {
        public static let sm: CGFloat = 640
        public static let md: CGFloat = 768
        public static let lg: CGFloat = 1024
        public static let xl: CGFloat = 1280
        public static let xxl: CGFloat = 1536
    }
}

// MARK: - Backward Compatibility Aliases
public typealias DS = HeroToken
public typealias DSButton = HeroButton
public typealias DSCard = HeroCard
public typealias DSCardHeader = HeroCardHeader
public typealias DSCardBody = HeroCardBody
public typealias DSCardFooter = HeroCardFooter
public typealias DSInput = HeroInput 
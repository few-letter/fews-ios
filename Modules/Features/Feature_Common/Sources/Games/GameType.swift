import SwiftUI

public enum GameType: String, CaseIterable, Identifiable {
//    case appleGame = "apple_game"
    case tetris
    case twentyFortyEight
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
//        case .appleGame:
//            return "Apple Game"
        case .tetris:
            return "Tetris"
        case .twentyFortyEight:
            return "2048"
        }
    }
    
    public var description: String {
        switch self {
//        case .appleGame:
//            return "Find apples that add up to 10!"
        case .tetris:
            return "Stack blocks to complete lines!"
        case .twentyFortyEight:
            return "Merge blocks with the same number to reach 2048!"
        }
    }
    
    public var icon: String {
        switch self {
//        case .appleGame:
//            return "plus.circle.fill"
        case .tetris:
            return "square.stack.3d.down.right"
        case .twentyFortyEight:
            return "grid"
        }
    }
    
    public var color: Color {
        switch self {
//        case .appleGame:
//            return .red
        case .tetris:
            return .cyan
        case .twentyFortyEight:
            return .orange
        }
    }
}

//
//  T.swift
//  CommonFeature
//
//  Created by 송영모 on 6/24/25.
//

import SwiftUI

// 테트리스 블록 타입
enum TetrisBlockType: CaseIterable {
    case I, O, T, S, Z, J, L
    
    var color: Color {
        switch self {
        case .I: return .cyan
        case .O: return .yellow
        case .T: return .purple
        case .S: return .green
        case .Z: return .red
        case .J: return .blue
        case .L: return .orange
        }
    }
    
    var shape: [[Bool]] {
        switch self {
        case .I: return [[true, true, true, true]]
        case .O: return [[true, true], [true, true]]
        case .T: return [[false, true, false], [true, true, true]]
        case .S: return [[false, true, true], [true, true, false]]
        case .Z: return [[true, true, false], [false, true, true]]
        case .J: return [[true, false, false], [true, true, true]]
        case .L: return [[false, false, true], [true, true, true]]
        }
    }
    
    // 회전된 모양 반환
    func rotatedShape(_ rotation: Int) -> [[Bool]] {
        var shape = self.shape
        for _ in 0..<(rotation % 4) {
            shape = rotateMatrix(shape)
        }
        return shape
    }
    
    private func rotateMatrix(_ matrix: [[Bool]]) -> [[Bool]] {
        let rows = matrix.count
        let cols = matrix[0].count
        var rotated = Array(repeating: Array(repeating: false, count: rows), count: cols)
        
        for i in 0..<rows {
            for j in 0..<cols {
                rotated[j][rows - 1 - i] = matrix[i][j]
            }
        }
        return rotated
    }
}

// 게임 상태 관리
class TetrisGame: ObservableObject {
    static let boardWidth = 10
    static let boardHeight = 20
    
    @Published var board: [[TetrisBlockType?]] = Array(repeating: Array(repeating: nil, count: boardWidth), count: boardHeight)
    @Published var currentBlock: TetrisBlockType = .I
    @Published var currentBlockPosition: (x: Int, y: Int) = (4, 0)
    @Published var currentBlockRotation: Int = 0
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var lines: Int = 0
    @Published var nextBlock: TetrisBlockType = .O
    @Published var isGameOver: Bool = false
    @Published var isPaused: Bool = false
    
    private var gameTimer: Timer?
    
    init() {
        currentBlock = TetrisBlockType.allCases.randomElement() ?? .I
        nextBlock = TetrisBlockType.allCases.randomElement() ?? .O
        startGame()
    }
    
    func startGame() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: max(0.1, 1.0 - Double(level) * 0.1), repeats: true) { _ in
            if !self.isPaused && !self.isGameOver {
                self.moveBlockDown()
            }
        }
    }
    
    func pauseGame() {
        isPaused.toggle()
    }
    
    func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: Self.boardWidth), count: Self.boardHeight)
        score = 0
        level = 1
        lines = 0
        isGameOver = false
        isPaused = false
        currentBlock = TetrisBlockType.allCases.randomElement() ?? .I
        nextBlock = TetrisBlockType.allCases.randomElement() ?? .O
        currentBlockPosition = (4, 0)
        currentBlockRotation = 0
        startGame()
    }
    
    func moveBlockLeft() {
        if canMove(dx: -1, dy: 0, rotation: currentBlockRotation) {
            currentBlockPosition.x -= 1
        }
    }
    
    func moveBlockRight() {
        if canMove(dx: 1, dy: 0, rotation: currentBlockRotation) {
            currentBlockPosition.x += 1
        }
    }
    
    func moveBlockDown() {
        if canMove(dx: 0, dy: 1, rotation: currentBlockRotation) {
            currentBlockPosition.y += 1
        } else {
            placeBlock()
            clearLines()
            spawnNewBlock()
        }
    }
    
    func dropBlock() {
        while canMove(dx: 0, dy: 1, rotation: currentBlockRotation) {
            currentBlockPosition.y += 1
        }
        placeBlock()
        clearLines()
        spawnNewBlock()
    }
    
    func rotateBlock() {
        let newRotation = (currentBlockRotation + 1) % 4
        if canMove(dx: 0, dy: 0, rotation: newRotation) {
            currentBlockRotation = newRotation
        }
    }
    
    private func canMove(dx: Int, dy: Int, rotation: Int) -> Bool {
        let newX = currentBlockPosition.x + dx
        let newY = currentBlockPosition.y + dy
        let shape = currentBlock.rotatedShape(rotation)
        
        for (row, shapeRow) in shape.enumerated() {
            for (col, hasBlock) in shapeRow.enumerated() {
                if hasBlock {
                    let boardX = newX + col
                    let boardY = newY + row
                    
                    // 경계 체크
                    if boardX < 0 || boardX >= Self.boardWidth || boardY >= Self.boardHeight {
                        return false
                    }
                    
                    // 다른 블록과 충돌 체크 (y가 음수인 경우는 아직 화면 위쪽이므로 허용)
                    if boardY >= 0 && board[boardY][boardX] != nil {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    private func placeBlock() {
        let shape = currentBlock.rotatedShape(currentBlockRotation)
        let x = currentBlockPosition.x
        let y = currentBlockPosition.y
        
        for (row, shapeRow) in shape.enumerated() {
            for (col, hasBlock) in shapeRow.enumerated() {
                if hasBlock {
                    let boardX = x + col
                    let boardY = y + row
                    
                    if boardY >= 0 && boardY < Self.boardHeight && boardX >= 0 && boardX < Self.boardWidth {
                        board[boardY][boardX] = currentBlock
                    }
                }
            }
        }
    }
    
    private func clearLines() {
        var linesCleared = 0
        
        for y in (0..<Self.boardHeight).reversed() {
            if board[y].allSatisfy({ $0 != nil }) {
                board.remove(at: y)
                board.insert(Array(repeating: nil, count: Self.boardWidth), at: 0)
                linesCleared += 1
            }
        }
        
        if linesCleared > 0 {
            lines += linesCleared
            score += linesCleared * 100 * level
            level = lines / 10 + 1
            startGame() // 레벨업시 속도 조정
        }
    }
    
    private func spawnNewBlock() {
        currentBlock = nextBlock
        nextBlock = TetrisBlockType.allCases.randomElement() ?? .I
        currentBlockPosition = (4, 0)
        currentBlockRotation = 0
        
        if !canMove(dx: 0, dy: 0, rotation: 0) {
            isGameOver = true
            gameTimer?.invalidate()
        }
    }
    
    // 현재 블록이 차지하는 위치인지 확인
    func isCurrentBlockPosition(row: Int, col: Int) -> Bool {
        let shape = currentBlock.rotatedShape(currentBlockRotation)
        let relativeRow = row - currentBlockPosition.y
        let relativeCol = col - currentBlockPosition.x
        
        if relativeRow >= 0 && relativeRow < shape.count &&
           relativeCol >= 0 && relativeCol < shape[relativeRow].count {
            return shape[relativeRow][relativeCol]
        }
        
        return false
    }
}

// 메인 테트리스 뷰
public struct TetrisGameView: View {
    @StateObject private var game = TetrisGame()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 15) {
            // 1. 상단 헤더
            HeaderView(game: game)
            
            // 2. 중앙 게임 보드
            GameBoard(game: game)
                .frame(width: 300, height: 400)
            
            // 3. 하단 컨트롤러
            GameControlButtons(game: game)
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .foregroundColor(.primary)
    }
}

// 상단 헤더뷰 - 가로 배치
struct HeaderView: View {
    @ObservedObject var game: TetrisGame
    
    var body: some View {
        HStack(spacing: 20) {
            // 점수 정보들
            HStack(spacing: 25) {
                VStack {
                    Text("SCORE")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Text("\(game.score)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                VStack {
                    Text("LEVEL")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    Text("\(game.level)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                VStack {
                    Text("LINES")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                    Text("\(game.lines)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            
            Spacer()
            
            // 다음 블록 미리보기
            VStack {
                Text("NEXT")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                
                VStack(spacing: 2) {
                    ForEach(0..<game.nextBlock.shape.count, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<game.nextBlock.shape[row].count, id: \.self) { col in
                                Rectangle()
                                    .fill(game.nextBlock.shape[row][col] ? game.nextBlock.color : Color.clear)
                                    .frame(width: 10, height: 10)
                                    .overlay(
                                        Rectangle()
                                            .stroke(game.nextBlock.shape[row][col] ? Color.primary.opacity(0.3) : Color.clear, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding(6)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(4)
            }
            
            Spacer()
            
            // 게임 상태 및 컨트롤
            HStack(spacing: 10) {
                if game.isGameOver {
                    Text("GAME OVER")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                } else if game.isPaused {
                    Text("PAUSED")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                Button(action: game.pauseGame) {
                    Text(game.isPaused ? "RESUME" : "PAUSE")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(game.isPaused ? Color.green : Color.orange)
                        .cornerRadius(6)
                }
                
                Button(action: game.resetGame) {
                    Text("RESET")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .cornerRadius(6)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// 게임 조작 버튼들
struct GameControlButtons: View {
    @ObservedObject var game: TetrisGame
    
    var body: some View {
        // 모든 버튼을 가로로 배치
        HStack(spacing: 20) {
            // 좌우 이동
            HStack(spacing: 10) {
                Button(action: game.moveBlockLeft) {
                    VStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                        Text("LEFT")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .frame(width: 60, height: 50)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                
                Button(action: game.moveBlockRight) {
                    VStack(spacing: 2) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                        Text("RIGHT")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .frame(width: 60, height: 50)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            
            // 회전 버튼
            Button(action: game.rotateBlock) {
                VStack(spacing: 2) {
                    Image(systemName: "rotate.right")
                        .font(.title3)
                    Text("ROTATE")
                        .font(.caption2)
                }
                .foregroundColor(.white)
                .frame(width: 70, height: 50)
                .background(Color.purple)
                .cornerRadius(8)
            }
            
            // 아래로 이동
            HStack(spacing: 10) {
                Button(action: game.moveBlockDown) {
                    VStack(spacing: 2) {
                        Image(systemName: "chevron.down")
                            .font(.title3)
                        Text("DOWN")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .frame(width: 60, height: 50)
                    .background(Color.gray)
                    .cornerRadius(8)
                }
                
                Button(action: game.dropBlock) {
                    VStack(spacing: 2) {
                        Image(systemName: "chevron.down.to.line")
                            .font(.title3)
                        Text("DROP")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .frame(width: 60, height: 50)
                    .background(Color.red)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// 게임 보드
struct GameBoard: View {
    @ObservedObject var game: TetrisGame
    
    var body: some View {
        VStack(spacing: 1) {
            ForEach(0..<TetrisGame.boardHeight, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<TetrisGame.boardWidth, id: \.self) { col in
                        BlockCell(
                            blockType: getCellType(row: row, col: col),
                            isCurrentBlock: game.isCurrentBlockPosition(row: row, col: col)
                        )
                    }
                }
            }
        }
        .background(Color(UIColor.systemGray6))
        .overlay(
            Rectangle()
                .stroke(Color.primary.opacity(0.3), lineWidth: 2)
        )
    }
    
    private func getCellType(row: Int, col: Int) -> TetrisBlockType? {
        if game.isCurrentBlockPosition(row: row, col: col) {
            return game.currentBlock
        }
        return game.board[row][col]
    }
}

// 개별 블록 셀
struct BlockCell: View {
    let blockType: TetrisBlockType?
    let isCurrentBlock: Bool
    
    var body: some View {
        Rectangle()
            .fill(blockType?.color ?? Color(UIColor.systemBackground))
            .frame(width: 30, height: 30) // 크기를 30x30으로 증가
            .overlay(
                Rectangle()
                    .stroke(
                        Color.primary.opacity(blockType != nil ? 0.3 : 0.1),
                        lineWidth: blockType != nil ? 1 : 0.5
                    )
            )
            .opacity(isCurrentBlock ? 0.8 : 1.0)
            .scaleEffect(isCurrentBlock ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isCurrentBlock)
    }
}

// 프리뷰
struct TetrisGameView_Previews: PreviewProvider {
    static var previews: some View {
        TetrisGameView()
    }
}

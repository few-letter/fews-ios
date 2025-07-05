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
    @State private var showingNewGameAlert = false
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 1. 상단 헤더
                HeaderView(game: game)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // 2. 중앙 게임 보드 - 세로 화면 최대 활용
                let availableHeight = geometry.size.height - 200 // 헤더와 컨트롤 공간 제외
                let gameboardHeight = max(availableHeight, 300) // 최소 높이 보장
                
                GameBoard(game: game)
                    .frame(width: min(geometry.size.width * 0.8, 250), 
                           height: gameboardHeight)
                    .padding(.vertical, 10)
                
                // 3. 게임 오버 또는 일시정지 상태 표시
                if game.isGameOver || game.isPaused {
                    GameStatusView(game: game, showingNewGameAlert: $showingNewGameAlert)
                        .padding(.vertical, 5)
                }
                
                // 4. 하단 컨트롤러
                GameControlButtons(game: game)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .disabled(game.isGameOver)
                    .opacity(game.isGameOver ? 0.5 : 1.0)
                
                Spacer(minLength: 0)
            }
        }
        .background(Color(UIColor.systemBackground))
        .alert("Start a new game?", isPresented: $showingNewGameAlert) {
            Button("Cancel", role: .cancel) { }
            Button("New Game", role: .destructive) {
                game.resetGame()
            }
        } message: {
            Text("Current game will be reset.")
        }
    }
}

// 게임 상태 표시 뷰
struct GameStatusView: View {
    @ObservedObject var game: TetrisGame
    @Binding var showingNewGameAlert: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            if game.isGameOver {
                Text("Game Over!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .scaleEffect(1.1)
                    .animation(.bouncy(duration: 0.6), value: game.isGameOver)
                
                Button(action: {
                    showingNewGameAlert = true
                }) {
                    Text("New Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            } else if game.isPaused {
                Text("Paused")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// 상단 헤더뷰 - 심플하게 정리
struct HeaderView: View {
    @ObservedObject var game: TetrisGame
    
    var body: some View {
        HStack {
            // 점수 정보들
            HStack(spacing: 15) {
                VStack {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(game.score)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .animation(.easeInOut(duration: 0.3), value: game.score)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                VStack {
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(game.level)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .animation(.easeInOut(duration: 0.3), value: game.level)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                VStack {
                    Text("Lines")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(game.lines)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .animation(.easeInOut(duration: 0.3), value: game.lines)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            
            Spacer()
            
            // 다음 블록 미리보기
            VStack {
                Text("Next")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 1) {
                    ForEach(0..<game.nextBlock.shape.count, id: \.self) { row in
                        HStack(spacing: 1) {
                            ForEach(0..<game.nextBlock.shape[row].count, id: \.self) { col in
                                Rectangle()
                                    .fill(game.nextBlock.shape[row][col] ? game.nextBlock.color : Color.clear)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
                .padding(4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
            }
            
            Spacer()
            
            // 게임 컨트롤
            HStack(spacing: 5) {
                Button(action: game.pauseGame) {
                    Text(game.isPaused ? "▶" : "⏸")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .frame(width: 25, height: 25)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
                .disabled(game.isGameOver)
                
                Button(action: {
                    if game.isGameOver {
                        game.resetGame()
                    } else {
                        game.resetGame()
                    }
                }) {
                    Text("↻")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .frame(width: 25, height: 25)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
    }
}

// 게임 조작 버튼들 - 심플하게
struct GameControlButtons: View {
    @ObservedObject var game: TetrisGame
    
    var body: some View {
        HStack(spacing: 20) {
            // 좌우 이동
            HStack(spacing: 8) {
                Button(action: game.moveBlockLeft) {
                    Text("◀")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Button(action: game.moveBlockRight) {
                    Text("▶")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            // 회전 버튼
            Button(action: game.rotateBlock) {
                Text("↻")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // 아래로 이동
            HStack(spacing: 8) {
                Button(action: game.moveBlockDown) {
                    Text("▼")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Button(action: game.dropBlock) {
                    Text("⬇")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
    }
}

// 게임 보드 - 심플하게
struct GameBoard: View {
    @ObservedObject var game: TetrisGame
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width / CGFloat(TetrisGame.boardWidth), 
                             geometry.size.height / CGFloat(TetrisGame.boardHeight))
            
            VStack(spacing: 1) {
                ForEach(0..<TetrisGame.boardHeight, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0..<TetrisGame.boardWidth, id: \.self) { col in
                            BlockCell(
                                blockType: getCellType(row: row, col: col),
                                isCurrentBlock: game.isCurrentBlockPosition(row: row, col: col),
                                cellSize: cellSize
                            )
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.gray.opacity(0.3))
            .overlay(
                Rectangle()
                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(8)
        }
    }
    
    private func getCellType(row: Int, col: Int) -> TetrisBlockType? {
        if game.isCurrentBlockPosition(row: row, col: col) {
            return game.currentBlock
        }
        return game.board[row][col]
    }
}

// 개별 블록 셀 - 심플하게
struct BlockCell: View {
    let blockType: TetrisBlockType?
    let isCurrentBlock: Bool
    let cellSize: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(blockType?.color ?? Color(UIColor.systemBackground))
            .frame(width: cellSize, height: cellSize)
            .overlay(
                Rectangle()
                    .stroke(
                        Color.primary.opacity(blockType != nil ? 0.2 : 0.05),
                        lineWidth: 0.5
                    )
            )
            .opacity(isCurrentBlock ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isCurrentBlock)
    }
}

// 프리뷰
struct TetrisGameView_Previews: PreviewProvider {
    static var previews: some View {
        TetrisGameView()
    }
}

import SwiftUI

struct Tile: Identifiable, Equatable {
    let id: Int
    var value: Int
    var position: Position
    var previousPosition: Position?
    var isNew: Bool = false
    var isMerged: Bool = false
    var mergedFromId: Int?
}

struct Position: Equatable, Hashable {
    var row: Int
    var col: Int
}

public struct TwentyFortyEightGameView: View {
    @StateObject private var gameModel = GameModel()
    @State private var showingNewGameAlert = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("2048")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                HStack {
                    VStack {
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(gameModel.score)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .animation(.easeInOut(duration: 0.3), value: gameModel.score)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    VStack {
                        Text("Best Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(gameModel.bestScore)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .animation(.easeInOut(duration: 0.3), value: gameModel.bestScore)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            
            GeometryReader { geometry in
                let boardSize = min(geometry.size.width, geometry.size.height - 100)
                let tileSize = (boardSize - 5 * 8) / 4
                
                ZStack {
                    VStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { row in
                            HStack(spacing: 8) {
                                ForEach(0..<4, id: \.self) { col in
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: tileSize, height: tileSize)
                                }
                            }
                        }
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(12)
                    
                    ForEach(gameModel.tiles) { tile in
                        AnimatedTileView(
                            tile: tile,
                            tileSize: tileSize,
                            boardSize: boardSize
                        )
                        .zIndex(tile.isMerged ? 1 : 0)
                    }
                    .padding(8)
                }
                .frame(width: boardSize, height: boardSize)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .frame(height: 400)
            
            VStack(spacing: 15) {
                if gameModel.isGameOver {
                    Text(gameModel.hasWon ? "You Win!" : "Game Over!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(gameModel.hasWon ? .green : .red)
                        .scaleEffect(gameModel.isGameOver ? 1.1 : 1.0)
                        .animation(.bouncy(duration: 0.6), value: gameModel.isGameOver)
                }
                
                Button(action: {
                    showingNewGameAlert = true
                }) {
                    Text("New Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                .alert("Start a new game?", isPresented: $showingNewGameAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("New Game", role: .destructive) {
                        gameModel.newGame()
                    }
                } message: {
                    Text("Current game will be reset.")
                }
                
                Text("Swipe to move tiles")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .gesture(
            DragGesture()
                .onEnded { value in
                    gameModel.handleSwipe(value: value)
                }
        )
        .onAppear {
            gameModel.newGame()
        }
    }
}

struct AnimatedTileView: View {
    let tile: Tile
    let tileSize: CGFloat
    let boardSize: CGFloat
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(tileColor)
                .frame(width: tileSize, height: tileSize)
            
            Text("\(tile.value)")
                .font(fontSize)
                .fontWeight(.bold)
                .foregroundColor(textColor)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(x: offsetX, y: offsetY)
        .onAppear {
            if tile.isNew {
                scale = 0.1
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    scale = 1.0
                }
            }
        }
        .onChange(of: tile.isMerged) { _, newValue in
            if newValue {
                withAnimation(.easeIn(duration: 0.1)) {
                    scale = 1.15
                }
                withAnimation(.easeOut(duration: 0.2).delay(0.1)) {
                    scale = 1.0
                }
            }
        }
    }
    
    private var offsetX: CGFloat {
        let spacing: CGFloat = 8
        let totalSpacing = spacing * 5
        let availableSpace = boardSize - totalSpacing
        let cellSize = availableSpace / 4
        
        return CGFloat(tile.position.col) * (cellSize + spacing) - (boardSize - tileSize) / 2 + spacing
    }
    
    private var offsetY: CGFloat {
        let spacing: CGFloat = 8
        let totalSpacing = spacing * 5
        let availableSpace = boardSize - totalSpacing
        let cellSize = availableSpace / 4
        
        return CGFloat(tile.position.row) * (cellSize + spacing) - (boardSize - tileSize) / 2 + spacing
    }
    
    private var tileColor: Color {
        switch tile.value {
        case 2: return Color(red: 0.93, green: 0.89, blue: 0.85)
        case 4: return Color(red: 0.93, green: 0.88, blue: 0.78)
        case 8: return Color(red: 0.95, green: 0.69, blue: 0.47)
        case 16: return Color(red: 0.96, green: 0.58, blue: 0.39)
        case 32: return Color(red: 0.96, green: 0.49, blue: 0.37)
        case 64: return Color(red: 0.96, green: 0.37, blue: 0.23)
        case 128: return Color(red: 0.93, green: 0.81, blue: 0.45)
        case 256: return Color(red: 0.93, green: 0.80, blue: 0.38)
        case 512: return Color(red: 0.93, green: 0.78, blue: 0.31)
        case 1024: return Color(red: 0.93, green: 0.77, blue: 0.25)
        case 2048: return Color(red: 0.93, green: 0.76, blue: 0.18)
        default: return Color.black
        }
    }
    
    private var textColor: Color {
        return tile.value <= 4 ? .primary : .white
    }
    
    private var fontSize: Font {
        switch tile.value {
        case 0...99: return .title2
        case 100...999: return .title3
        default: return .headline
        }
    }
}

class GameModel: ObservableObject {
    @Published var tiles: [Tile] = []
    @Published var score: Int = 0
    @Published var bestScore: Int = 0
    @Published var isGameOver: Bool = false
    @Published var hasWon: Bool = false
    
    private var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    private var nextTileId = 0
    
    init() {
        loadBestScore()
    }
    
    func newGame() {
        board = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        tiles.removeAll()
        score = 0
        isGameOver = false
        hasWon = false
        nextTileId = 0
        
        addRandomTile()
        addRandomTile()
    }
    
    func handleSwipe(value: DragGesture.Value) {
        guard !isGameOver else { return }
        
        let threshold: CGFloat = 50
        let horizontalDistance = value.translation.width
        let verticalDistance = value.translation.height
        
        if abs(horizontalDistance) > abs(verticalDistance) {
            if horizontalDistance > threshold {
                moveRight()
            } else if horizontalDistance < -threshold {
                moveLeft()
            }
        } else {
            if verticalDistance > threshold {
                moveDown()
            } else if verticalDistance < -threshold {
                moveUp()
            }
        }
    }
    
    private func moveLeft() {
        var moved = false
        let oldTiles = tiles
        var newTiles: [Tile] = []
        var tileMap: [Position: Tile] = [:]
        
        for tile in tiles {
            tileMap[tile.position] = tile
        }
        
        for row in 0..<4 {
            var rowTiles: [Tile] = []
            var mergedPositions: Set<Int> = []
            
            for col in 0..<4 {
                if let tile = tileMap[Position(row: row, col: col)] {
                    rowTiles.append(tile)
                }
            }
            
            var targetCol = 0
            for var tile in rowTiles {
                tile.previousPosition = tile.position
                tile.isMerged = false
                
                if targetCol > 0 && !mergedPositions.contains(targetCol - 1) {
                    if let lastTile = newTiles.last(where: { $0.position.row == row && $0.position.col == targetCol - 1 }) {
                        if lastTile.value == tile.value {
                            var mergedTile = lastTile
                            mergedTile.value *= 2
                            mergedTile.isMerged = true
                            mergedTile.mergedFromId = tile.id
                            
                            newTiles.removeAll { $0.id == lastTile.id }
                            newTiles.append(mergedTile)
                            
                            mergedPositions.insert(targetCol - 1)
                            score += mergedTile.value
                            moved = true
                            continue
                        }
                    }
                }
                
                tile.position = Position(row: row, col: targetCol)
                if tile.previousPosition != tile.position {
                    moved = true
                }
                newTiles.append(tile)
                targetCol += 1
            }
            
            for col in 0..<4 {
                board[row][col] = 0
            }
            for tile in newTiles.filter({ $0.position.row == row }) {
                board[row][tile.position.col] = tile.value
            }
        }
        
        if moved {
            withAnimation(.easeInOut(duration: 0.15)) {
                tiles = newTiles
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.addRandomTile()
                self.checkGameState()
            }
        }
    }
    
    private func moveRight() {
        var moved = false
        let oldTiles = tiles
        var newTiles: [Tile] = []
        var tileMap: [Position: Tile] = [:]
        
        for tile in tiles {
            tileMap[tile.position] = tile
        }
        
        for row in 0..<4 {
            var rowTiles: [Tile] = []
            var mergedPositions: Set<Int> = []
            
            for col in (0..<4).reversed() {
                if let tile = tileMap[Position(row: row, col: col)] {
                    rowTiles.append(tile)
                }
            }
            
            var targetCol = 3
            for var tile in rowTiles {
                tile.previousPosition = tile.position
                tile.isMerged = false
                
                if targetCol < 3 && !mergedPositions.contains(targetCol + 1) {
                    if let lastTile = newTiles.last(where: { $0.position.row == row && $0.position.col == targetCol + 1 }) {
                        if lastTile.value == tile.value {
                            var mergedTile = lastTile
                            mergedTile.value *= 2
                            mergedTile.isMerged = true
                            mergedTile.mergedFromId = tile.id
                            
                            newTiles.removeAll { $0.id == lastTile.id }
                            newTiles.append(mergedTile)
                            
                            mergedPositions.insert(targetCol + 1)
                            score += mergedTile.value
                            moved = true
                            continue
                        }
                    }
                }
                
                tile.position = Position(row: row, col: targetCol)
                if tile.previousPosition != tile.position {
                    moved = true
                }
                newTiles.append(tile)
                targetCol -= 1
            }
            
            for col in 0..<4 {
                board[row][col] = 0
            }
            for tile in newTiles.filter({ $0.position.row == row }) {
                board[row][tile.position.col] = tile.value
            }
        }
        
        if moved {
            withAnimation(.easeInOut(duration: 0.15)) {
                tiles = newTiles
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.addRandomTile()
                self.checkGameState()
            }
        }
    }
    
    private func moveUp() {
        var moved = false
        let oldTiles = tiles
        var newTiles: [Tile] = []
        var tileMap: [Position: Tile] = [:]
        
        for tile in tiles {
            tileMap[tile.position] = tile
        }
        
        for col in 0..<4 {
            var colTiles: [Tile] = []
            var mergedPositions: Set<Int> = []
            
            for row in 0..<4 {
                if let tile = tileMap[Position(row: row, col: col)] {
                    colTiles.append(tile)
                }
            }
            
            var targetRow = 0
            for var tile in colTiles {
                tile.previousPosition = tile.position
                tile.isMerged = false
                
                if targetRow > 0 && !mergedPositions.contains(targetRow - 1) {
                    if let lastTile = newTiles.last(where: { $0.position.col == col && $0.position.row == targetRow - 1 }) {
                        if lastTile.value == tile.value {
                            var mergedTile = lastTile
                            mergedTile.value *= 2
                            mergedTile.isMerged = true
                            mergedTile.mergedFromId = tile.id
                            
                            newTiles.removeAll { $0.id == lastTile.id }
                            newTiles.append(mergedTile)
                            
                            mergedPositions.insert(targetRow - 1)
                            score += mergedTile.value
                            moved = true
                            continue
                        }
                    }
                }
                
                tile.position = Position(row: targetRow, col: col)
                if tile.previousPosition != tile.position {
                    moved = true
                }
                newTiles.append(tile)
                targetRow += 1
            }
            
            for row in 0..<4 {
                board[row][col] = 0
            }
            for tile in newTiles.filter({ $0.position.col == col }) {
                board[tile.position.row][col] = tile.value
            }
        }
        
        if moved {
            withAnimation(.easeInOut(duration: 0.15)) {
                tiles = newTiles
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.addRandomTile()
                self.checkGameState()
            }
        }
    }
    
    private func moveDown() {
        var moved = false
        let oldTiles = tiles
        var newTiles: [Tile] = []
        var tileMap: [Position: Tile] = [:]
        
        for tile in tiles {
            tileMap[tile.position] = tile
        }
        
        for col in 0..<4 {
            var colTiles: [Tile] = []
            var mergedPositions: Set<Int> = []
            
            for row in (0..<4).reversed() {
                if let tile = tileMap[Position(row: row, col: col)] {
                    colTiles.append(tile)
                }
            }
            
            var targetRow = 3
            for var tile in colTiles {
                tile.previousPosition = tile.position
                tile.isMerged = false
                
                if targetRow < 3 && !mergedPositions.contains(targetRow + 1) {
                    if let lastTile = newTiles.last(where: { $0.position.col == col && $0.position.row == targetRow + 1 }) {
                        if lastTile.value == tile.value {
                            var mergedTile = lastTile
                            mergedTile.value *= 2
                            mergedTile.isMerged = true
                            mergedTile.mergedFromId = tile.id
                            
                            newTiles.removeAll { $0.id == lastTile.id }
                            newTiles.append(mergedTile)
                            
                            mergedPositions.insert(targetRow + 1)
                            score += mergedTile.value
                            moved = true
                            continue
                        }
                    }
                }
                
                tile.position = Position(row: targetRow, col: col)
                if tile.previousPosition != tile.position {
                    moved = true
                }
                newTiles.append(tile)
                targetRow -= 1
            }
            
            for row in 0..<4 {
                board[row][col] = 0
            }
            for tile in newTiles.filter({ $0.position.col == col }) {
                board[tile.position.row][col] = tile.value
            }
        }
        
        if moved {
            withAnimation(.easeInOut(duration: 0.15)) {
                tiles = newTiles
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.addRandomTile()
                self.checkGameState()
            }
        }
    }
    
    private func addRandomTile() {
        let emptyCells = getEmptyCells()
        guard !emptyCells.isEmpty else { return }
        
        let randomIndex = Int.random(in: 0..<emptyCells.count)
        let (row, col) = emptyCells[randomIndex]
        let value = Int.random(in: 1...10) <= 9 ? 2 : 4
        
        board[row][col] = value
        
        let newTile = Tile(
            id: nextTileId,
            value: value,
            position: Position(row: row, col: col),
            isNew: true
        )
        nextTileId += 1
        
        tiles.append(newTile)
    }
    
    private func getEmptyCells() -> [(Int, Int)] {
        var emptyCells: [(Int, Int)] = []
        for row in 0..<4 {
            for col in 0..<4 {
                if board[row][col] == 0 {
                    emptyCells.append((row, col))
                }
            }
        }
        return emptyCells
    }
    
    private func checkGameState() {
        updateBestScore()
        
        for row in 0..<4 {
            for col in 0..<4 {
                if board[row][col] >= 2048 && !hasWon {
                    hasWon = true
                    return
                }
            }
        }
        
        if getEmptyCells().isEmpty && !canMove() {
            isGameOver = true
        }
    }
    
    private func canMove() -> Bool {
        for row in 0..<4 {
            for col in 0..<3 {
                if board[row][col] == board[row][col + 1] {
                    return true
                }
            }
        }
        
        for row in 0..<3 {
            for col in 0..<4 {
                if board[row][col] == board[row + 1][col] {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func updateBestScore() {
        if score > bestScore {
            bestScore = score
            saveBestScore()
        }
    }
    
    private func saveBestScore() {
        UserDefaults.standard.set(bestScore, forKey: "BestScore2048")
    }
    
    private func loadBestScore() {
        bestScore = UserDefaults.standard.integer(forKey: "BestScore2048")
    }
}

#Preview {
    TwentyFortyEightGameView()
}

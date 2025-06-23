import SwiftUI

public struct Apple: Identifiable, Equatable {
    public let id = UUID()
    let number: Int
    let row: Int
    let col: Int
    var isSelected: Bool = false
    var isRemoved: Bool = false
    var isRemoving: Bool = false // 제거 애니메이션 상태
}

public struct AppleGameView: View {
    @State private var apples: [[Apple]] = []
    @State private var selectedApples: Set<UUID> = []
    @State private var score = 0
    @State private var timeRemaining = 120.0 // 2분
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var gameTimer: Timer?
    @State private var dragStartPosition: CGPoint?
    @State private var dragCurrentPosition: CGPoint?
    @State private var isDragging = false
    @State private var selectedSum = 0
    @State private var scoreAnimationTrigger = false // 점수 애니메이션
    @State private var showPerfectMessage = false // 퍼펙트 메시지 애니메이션
    
    private let rows = 17
    private let cols = 10
    private let spacing: CGFloat = 3 // 사과 간격
    
    public var body: some View {
        GeometryReader { geometry in
            // 화면 크기에 맞게 cellSize 계산
            let availableWidth = geometry.size.width - 40 // 좌우 여백
            let availableHeight = geometry.size.height * 0.65 // 게임 영역 높이 (헤더 제외)
            
            // 가로세로 비율을 고려해서 적절한 cellSize 계산
            let cellSizeByWidth = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
            let cellSizeByHeight = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)
            let cellSize = min(cellSizeByWidth, cellSizeByHeight, 45) // 최대 45로 제한
            
            ZStack {
                // 배경
                Color.white
                    .ignoresSafeArea()
                
                if gameOver {
                    // 게임 오버 화면
                    VStack(spacing: 30) {
                        Text("⏰")
                            .font(.system(size: 80))
                            .rotationEffect(.degrees(showPerfectMessage ? 360 : 0))
                            .animation(.easeInOut(duration: 1.0), value: showPerfectMessage)
                        
                        Text("시간 종료!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .scaleEffect(showPerfectMessage ? 1.1 : 1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showPerfectMessage)
                        
                        Text("최종 점수: \(score)")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .scaleEffect(scoreAnimationTrigger ? 1.2 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: scoreAnimationTrigger)
                        
                        Text("남은 사과: \(countRemainingApples())")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .offset(y: showPerfectMessage ? -5 : 0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showPerfectMessage)
                        
                        if score == 170 {
                            Text("🎉 PERFECT! 🎉")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                                .scaleEffect(showPerfectMessage ? 1.3 : 0.8)
                                .opacity(showPerfectMessage ? 1.0 : 0.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.5), value: showPerfectMessage)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                                        showPerfectMessage = true
                                    }
                                }
                        }
                        
                        Button("다시 시작") {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                resetGame()
                            }
                        }
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Color.blue)
                        .cornerRadius(25)
                        .scaleEffect(showPerfectMessage ? 1.05 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showPerfectMessage)
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                            scoreAnimationTrigger = true
                        }
                    }
                } else {
                    // 게임 화면
                    VStack(spacing: 10) {
                        // 상단 정보 (고정 높이)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("점수: \(score)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .scaleEffect(scoreAnimationTrigger ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: scoreAnimationTrigger)
                                    .foregroundColor(scoreAnimationTrigger ? .green : .primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("시간: \(Int(timeRemaining))초")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(timeRemaining < 30 ? .red : .primary)
                                    .scaleEffect(timeRemaining < 10 && Int(timeRemaining) % 2 == 0 ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.5), value: Int(timeRemaining))
                                
                                // 타이머 바
                                ProgressView(value: timeRemaining, total: 120.0)
                                    .frame(width: 100)
                                    .tint(timeRemaining < 30 ? .red : .blue)
                                    .scaleEffect(timeRemaining < 10 ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: timeRemaining < 10)
                            }
                        }
                        .frame(height: 60) // 헤더 높이 고정
                        .padding(.horizontal)
                        
                        // 사과 격자 - 화면 중앙에 배치 (스크롤 방지)
                        HStack {
                            Spacer()
                            
                            ZStack {
                                // 드래그 영역 표시
                                if isDragging,
                                   let startPos = dragStartPosition,
                                   let currentPos = dragCurrentPosition {
                                    Rectangle()
                                        .fill(Color.blue.opacity(0.2))
                                        .border(selectedSum == 10 ? Color.green : Color.blue, width: 2)
                                        .frame(
                                            width: abs(currentPos.x - startPos.x),
                                            height: abs(currentPos.y - startPos.y)
                                        )
                                        .position(
                                            x: (startPos.x + currentPos.x) / 2,
                                            y: (startPos.y + currentPos.y) / 2
                                        )
                                        .scaleEffect(isDragging ? 1.0 : 0.0)
                                        .opacity(isDragging ? 1.0 : 0.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                                }
                                
                                // 사과들
                                VStack(spacing: spacing) {
                                    ForEach(0..<rows, id: \.self) { row in
                                        HStack(spacing: spacing) {
                                            ForEach(0..<cols, id: \.self) { col in
                                                if row < apples.count && col < apples[row].count && !apples[row][col].isRemoved {
                                                    AnimatedAppleView(
                                                        apple: apples[row][col],
                                                        cellSize: cellSize
                                                    )
                                                } else {
                                                    Rectangle()
                                                        .fill(Color.clear)
                                                        .frame(width: cellSize, height: cellSize)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .background(Color.clear)
                            .clipped() // 게임 영역 클리핑으로 스크롤 방지
                            .contentShape(Rectangle()) // 터치 영역 명확히 정의
                            .gesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                    .onChanged { value in
                                        if dragStartPosition == nil {
                                            dragStartPosition = value.startLocation
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                isDragging = true
                                            }
                                        }
                                        dragCurrentPosition = value.location
                                        updateSelection(cellSize: cellSize)
                                    }
                                    .onEnded { value in
                                        if selectedSum == 10 && !selectedApples.isEmpty {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                removeSelectedApples()
                                            }
                                        }
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            clearSelection()
                                        }
                                    }
                            )
                            .simultaneousGesture(
                                // 스크롤 제스처 차단
                                DragGesture()
                                    .onChanged { _ in }
                            )
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale),
                        removal: .opacity.combined(with: .scale)
                    ))
                }
            }
        }
        .onAppear {
            // 게임 자동 시작 (약간의 지연으로 안전하게)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !gameStarted && !gameOver {
                    startGame()
                }
            }
        }
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            if gameStarted && !gameOver {
                timeRemaining -= 0.1
                if timeRemaining <= 0 {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        endGame()
                    }
                }
            }
        }
    }
    
    func startGame() {
        gameStarted = true
        gameOver = false
        score = 0
        timeRemaining = 120.0
        scoreAnimationTrigger = false
        showPerfectMessage = false
        generateApples()
    }
    
    func resetGame() {
        gameStarted = false
        gameOver = false
        score = 0
        timeRemaining = 120.0
        selectedApples.removeAll()
        selectedSum = 0
        scoreAnimationTrigger = false
        showPerfectMessage = false
    }
    
    func endGame() {
        gameStarted = false
        gameOver = true
    }
    
    func generateApples() {
        apples = []
        var totalSum = 0
        
        // 10x17 = 170개의 사과 생성
        for row in 0..<rows {
            var appleRow: [Apple] = []
            for col in 0..<cols {
                let number = Int.random(in: 1...9)
                let apple = Apple(number: number, row: row, col: col)
                appleRow.append(apple)
                totalSum += number
            }
            apples.append(appleRow)
        }
        
        // 총합이 10의 배수가 되도록 조정
        let remainder = totalSum % 10
        if remainder != 0 {
            let adjustment = 10 - remainder
            // 랜덤한 위치의 사과 숫자를 조정
            let randomRow = Int.random(in: 0..<rows)
            let randomCol = Int.random(in: 0..<cols)
            let currentNumber = apples[randomRow][randomCol].number
            let newNumber = min(9, currentNumber + adjustment)
            
            apples[randomRow][randomCol] = Apple(
                number: newNumber,
                row: randomRow,
                col: randomCol
            )
        }
    }
    
    func updateSelection(cellSize: CGFloat) {
        guard let startPos = dragStartPosition,
              let currentPos = dragCurrentPosition,
              !apples.isEmpty,
              apples.count >= rows else { return }
        
        let minX = min(startPos.x, currentPos.x)
        let maxX = max(startPos.x, currentPos.x)
        let minY = min(startPos.y, currentPos.y)
        let maxY = max(startPos.y, currentPos.y)
        
        selectedApples.removeAll()
        selectedSum = 0
        
        // 선택 영역 내의 사과들 찾기 (드래그가 원을 스치기만 해도 선택)
        for row in 0..<rows {
            guard row < apples.count, apples[row].count >= cols else { continue }
            for col in 0..<cols {
                guard col < apples[row].count else { continue }
                
                if !apples[row][col].isRemoved {
                    let appleX = CGFloat(col) * (cellSize + spacing) + cellSize / 2
                    let appleY = CGFloat(row) * (cellSize + spacing) + cellSize / 2
                    let radius = cellSize / 2
                    
                    // 원과 사각형의 교집합 검사 (민감도 높임)
                    let closestX = max(minX, min(appleX, maxX))
                    let closestY = max(minY, min(appleY, maxY))
                    let distanceX = appleX - closestX
                    let distanceY = appleY - closestY
                    let distanceSquared = distanceX * distanceX + distanceY * distanceY
                    
                    if distanceSquared <= radius * radius {
                        selectedApples.insert(apples[row][col].id)
                        selectedSum += apples[row][col].number
                        apples[row][col].isSelected = true
                    } else {
                        apples[row][col].isSelected = false
                    }
                }
            }
        }
    }
    
    func removeSelectedApples() {
        guard !apples.isEmpty, apples.count >= rows else { return }
        
        for row in 0..<rows {
            guard row < apples.count, apples[row].count >= cols else { continue }
            for col in 0..<cols {
                guard col < apples[row].count else { continue }
                
                if selectedApples.contains(apples[row][col].id) {
                    apples[row][col].isRemoving = true
                    
                    // 지연된 제거로 애니메이션 효과
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if row < self.apples.count && col < self.apples[row].count {
                            self.apples[row][col].isRemoved = true
                            self.score += 1
                            
                            // 점수 증가 애니메이션
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                self.scoreAnimationTrigger.toggle()
                            }
                            
                            // 점수 색상 되돌리기
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    self.scoreAnimationTrigger.toggle()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func clearSelection() {
        dragStartPosition = nil
        dragCurrentPosition = nil
        isDragging = false
        selectedApples.removeAll()
        selectedSum = 0
        
        guard !apples.isEmpty, apples.count >= rows else { return }
        
        for row in 0..<rows {
            guard row < apples.count, apples[row].count >= cols else { continue }
            for col in 0..<cols {
                guard col < apples[row].count else { continue }
                apples[row][col].isSelected = false
            }
        }
    }
    
    func countRemainingApples() -> Int {
        guard !apples.isEmpty else { return 0 }
        
        var count = 0
        for row in 0..<min(rows, apples.count) {
            guard row < apples.count else { continue }
            for col in 0..<min(cols, apples[row].count) {
                guard col < apples[row].count else { continue }
                if !apples[row][col].isRemoved {
                    count += 1
                }
            }
        }
        return count
    }
}

public struct AnimatedAppleView: View {
    let apple: Apple
    let cellSize: CGFloat
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(apple.isSelected ? Color.green.opacity(0.7) : Color.red.opacity(0.8))
                .frame(width: cellSize, height: cellSize)
                .scaleEffect(apple.isSelected ? 1.1 : (apple.isRemoving ? 0.1 : 1.0))
                .opacity(apple.isRemoving ? 0.0 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: apple.isSelected)
                .animation(.easeInOut(duration: 0.3), value: apple.isRemoving)
                .shadow(color: apple.isSelected ? .green.opacity(0.5) : .clear, radius: 3, x: 0, y: 2)
                .animation(.easeInOut(duration: 0.2), value: apple.isSelected)
            
            Text("\(apple.number)")
                .font(.system(size: cellSize * 0.6, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(apple.isSelected ? 1.2 : (apple.isRemoving ? 0.1 : 1.0))
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: apple.isSelected)
                .animation(.easeInOut(duration: 0.3), value: apple.isRemoving)
        }
        .rotationEffect(.degrees(apple.isRemoving ? 360 : 0))
        .animation(.easeInOut(duration: 0.3), value: apple.isRemoving)
    }
}

public struct ContentView: View {
    public var body: some View {
        AppleGameView()
    }
}

#Preview {
    ContentView()
}

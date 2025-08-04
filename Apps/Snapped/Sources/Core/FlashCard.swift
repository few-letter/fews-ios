//
//  FlashCard.swift
//  Snapped
//
//  Created by 송영모 on 8/5/25.
//

import SwiftUI

// TOEICFlashcard struct (이전 설계 그대로 사용)
struct TOEICFlashcard: Codable, Identifiable {
  let id = UUID()
  let word: String
  let partOfSpeech: String
  let pronunciation: String
  let meanings: [String]
  let examples: [String]
}

// 메인 뷰: 단일 카드 스택 형태로 표시
struct ContentView: View {
  @State private var flashcards: [TOEICFlashcard] = []
  @State private var currentIndex = 0
  @State private var reviewCards: [TOEICFlashcard] = []
  @State private var completedCards: [TOEICFlashcard] = []

  var body: some View {
    NavigationStack {
      VStack {
        // 진행 상황 표시
        HStack {
          Text("진행: \(currentIndex + 1)/\(totalCards)")
            .font(.headline)
          Spacer()
          Text("복습: \(reviewCards.count)")
            .font(.subheadline)
            .foregroundColor(.red)
          Text("완료: \(completedCards.count)")
            .font(.subheadline)
            .foregroundColor(.green)
        }
        .padding(.horizontal)
        
        // 카드 표시 영역
        ZStack {
          if let currentCard = currentCards.first {
            FlashCardView(
              card: currentCard,
              onSwipeLeft: { handleSwipeLeft(currentCard) },
              onSwipeRight: { handleSwipeRight(currentCard) }
            )
          } else {
            // 모든 카드 완료
            VStack(spacing: 20) {
              Text("🎉 모든 카드 완료!")
                .font(.largeTitle)
                .bold()
              
              Button("다시 시작") {
                resetCards()
              }
              .padding()
              .background(Color.blue)
              .foregroundColor(.white)
              .cornerRadius(10)
            }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        

      }
      .navigationTitle("TOEIC Flashcards")
      .onAppear {
        loadFlashcards()
      }
    }
  }
  
  private var totalCards: Int {
    flashcards.count + reviewCards.count
  }
  
  private var currentCards: [TOEICFlashcard] {
    Array(allRemainingCards.prefix(1)) // 한 번에 하나의 카드만 표시
  }
  
  private var allRemainingCards: [TOEICFlashcard] {
    if currentIndex < flashcards.count {
      return Array(flashcards[currentIndex...]) + reviewCards
    } else {
      return reviewCards
    }
  }
  
  private func getCurrentCardIndex(for stackIndex: Int) -> Int {
    return currentCards.count - 1 - stackIndex
  }
  
  private func handleSwipeLeft(_ card: TOEICFlashcard) {
    // 복습 카드에 추가
    if !reviewCards.contains(where: { $0.id == card.id }) {
      reviewCards.append(card)
    }
    moveToNextCard()
  }
  
  private func handleSwipeRight(_ card: TOEICFlashcard) {
    // 완료 카드에 추가
    completedCards.append(card)
    moveToNextCard()
  }
  
  private func moveToNextCard() {
    withAnimation(.easeInOut(duration: 0.3)) {
      if currentIndex < flashcards.count {
        currentIndex += 1
      } else if !reviewCards.isEmpty {
        reviewCards.removeFirst()
      }
    }
  }
  
  private func resetCards() {
    currentIndex = 0
    reviewCards.removeAll()
    completedCards.removeAll()
  }

  func loadFlashcards() {
    guard let url = Bundle.main.url(forResource: "toeic_flashcards", withExtension: "json"),
          let data = try? Data(contentsOf: url)
    else {
      print("JSON 로드 실패")
      return
    }

    do {
      let decoder = JSONDecoder()
      flashcards = try decoder.decode([TOEICFlashcard].self, from: data)
    } catch {
      print("디코딩 에러: \(error)")
    }
  }
}

// 개별 플래시카드 뷰: 3D 플립 애니메이션과 스와이프 제스처
struct FlashCardView: View {
  let card: TOEICFlashcard
  let onSwipeLeft: () -> Void
  let onSwipeRight: () -> Void
  
  @State private var isFlipped = false
  @State private var dragOffset = CGSize.zero
  @State private var dragColor = Color.clear
  
  var body: some View {
    ZStack {
      // 카드 앞면
      if !isFlipped {
        VStack(spacing: 15) {
          Text(card.word)
            .font(.largeTitle)
            .bold()
            .foregroundColor(.primary)

          Text(card.partOfSpeech)
            .font(.title3)
            .foregroundColor(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)

          Text(card.pronunciation)
            .font(.title2)
            .foregroundColor(.blue)
            .italic()
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(Color.white) // 완전 불투명한 흰색 배경
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .overlay(
              RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue, lineWidth: 3)
            )
        )
      }
      
      // 카드 뒷면
      if isFlipped {
        VStack(alignment: .leading, spacing: 20) {
          VStack(alignment: .leading, spacing: 10) {
            Text("뜻")
              .font(.headline)
              .foregroundColor(.primary)
            
            ForEach(card.meanings, id: \.self) { meaning in
              Text("• \(meaning)")
                .font(.body)
                .foregroundColor(.secondary)
            }
          }

          VStack(alignment: .leading, spacing: 10) {
            Text("예문")
              .font(.headline)
              .foregroundColor(.primary)
            
            ForEach(card.examples, id: \.self) { example in
              Text("\" \(example) \"")
                .font(.body)
                .italic()
                .foregroundColor(.secondary)
                .padding(.leading, 10)
            }
          }
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(Color.white) // 완전 불투명한 흰색 배경
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .overlay(
              RoundedRectangle(cornerRadius: 20)
                .stroke(Color.green, lineWidth: 3)
            )
        )
        .rotation3DEffect(
          .degrees(180), // 뒷면 텍스트 반전 해결
          axis: (x: 0, y: 1, z: 0)
        )
      }
    }
    .frame(width: 300, height: 400)
    .rotation3DEffect(
      .degrees(isFlipped ? 180 : 0),
      axis: (x: 0, y: 1, z: 0)
    )
    .offset(dragOffset)
    .scaleEffect(1.0 - abs(dragOffset.width) / 1000)
    .overlay(
      // 스와이프 색상 표시
      RoundedRectangle(cornerRadius: 20)
        .fill(dragColor.opacity(0.3))
        .allowsHitTesting(false)
    )
    .onTapGesture {
      withAnimation(.easeInOut(duration: 0.6)) {
        isFlipped.toggle()
      }
    }
    .gesture(
      DragGesture()
        .onChanged { value in
          dragOffset = value.translation
          
          // 드래그 방향에 따른 색상 변경
          if value.translation.width < -50 {
            dragColor = Color.red
          } else if value.translation.width > 50 {
            dragColor = Color.green
          } else {
            dragColor = Color.clear
          }
        }
        .onEnded { value in
          let threshold: CGFloat = 100
          
          if value.translation.width < -threshold {
            // 왼쪽 스와이프 - 다시 보기
            withAnimation(.easeOut(duration: 0.3)) {
              dragOffset = CGSize(width: -500, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
              onSwipeLeft()
              resetCard()
            }
          } else if value.translation.width > threshold {
            // 오른쪽 스와이프 - 완료
            withAnimation(.easeOut(duration: 0.3)) {
              dragOffset = CGSize(width: 500, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
              onSwipeRight()
              resetCard()
            }
          } else {
            // 원래 위치로 복귀
            withAnimation(.spring()) {
              resetCard()
            }
          }
        }
    )
  }
  
  private func resetCard() {
    dragOffset = .zero
    dragColor = .clear
    isFlipped = false
  }
}

#Preview {
  ContentView()
}

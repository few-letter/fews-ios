////
////  ContentView.swift
////  MultiTouchDragResizeRotateDemo + GridSnap
////
////  Created by ChatGPT on 2025-06-12.
////  (2025-06-14 — 회전+리사이즈)
////  (2025-06-15 — 그리드 · 점성 · 스냅 & 버그픽스)
////  (2025-06-16 — 회전 각도 스냅 추가)
////
//
//import SwiftUI
//
//// MARK: - SwiftUI 화면
//
//public struct ContentView: View {
//    
//    public var body: some View {
//        ZStack {
//            // 드래그 가능한 뷰
//            DraggableView(
//                items: [
//                    DraggableItem(rect: .init(x: 50, y: 100, width: 100, height: 100)),
//                    DraggableItem(rect: .init(x: 200, y: 250, width: 120, height: 120)),
//                    DraggableItem(rect: .init(x: 100, y: 400, width: 80, height: 80))
//                ],
//                gridLines: [
//                    // 수직
//                    GridLine(orientation: .vertical, position: 80),
//                    GridLine(orientation: .vertical, position: 160),
//                    GridLine(orientation: .vertical, position: 240),
//                    // 수평
//                    GridLine(orientation: .horizontal, position: 200),
//                    GridLine(orientation: .horizontal, position: 350),
//                    GridLine(orientation: .horizontal, position: 500)
//                ],
//                itemColors: [.red, .green, .blue, .orange, .purple],
//                showInfo: true
//            )
//            
//            // 사용법 안내
//            VStack {
//                Spacer()
//                howToBox.padding(.bottom, 50)
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(
//            LinearGradient(
//                colors: [
//                    .blue.opacity(0.1),
//                    .purple.opacity(0.1),
//                    .pink.opacity(0.05)
//                ],
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//        )
//    }
//    
//    private var howToBox: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("사용법:")
//                .font(.headline)
//            Group {
//                Text("• 박스를 터치해 이동")
//                Text("• 이동 중 다른 손가락 → 크기+회전")
//                Text("• 모서리가 그리드 근처에서 색이 바뀌면 '스냅' 가능!")
//                Text("• 회전 시 0°, 90°, 180°, 270°에서 자동 스냅")
//            }
//            .font(.caption)
//            .foregroundColor(.secondary)
//        }
//        .padding()
//        .background(Color.black.opacity(0.05))
//        .cornerRadius(12)
//    }
//}
//
//#if DEBUG
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View { 
//        ContentView() 
//    }
//}
//#endif

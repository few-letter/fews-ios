import SwiftUI
import ComposableArchitecture
import SwiftData

@main
struct FewCutsApp: App {
    var body: some Scene {
        WindowGroup {
            DraggableView(
                items: [
                    DraggableItem(rect: .init(x: 50, y: 100, width: 100, height: 100)),
                    DraggableItem(rect: .init(x: 200, y: 250, width: 120, height: 120)),
                    DraggableItem(rect: .init(x: 100, y: 400, width: 80, height: 80))
                ],
                gridLines: [
                    // 수직
                    GridLine(orientation: .vertical, position: 80),
                    GridLine(orientation: .vertical, position: 160),
                    GridLine(orientation: .vertical, position: 240),
                    // 수평
                    GridLine(orientation: .horizontal, position: 200),
                    GridLine(orientation: .horizontal, position: 350),
                    GridLine(orientation: .horizontal, position: 500)
                ],
            )
        }
        .modelContainer(for: [
            
        ])
    }
}

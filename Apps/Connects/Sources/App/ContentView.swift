//
//  ContentView.swift
//  Connects
//
//  Created by 송영모 on 6/12/25.
//

import SwiftUI

public struct Item: Identifiable {
    public let id = UUID()
    var rect: CGRect
}

class DragViewModel: ObservableObject {
    @Published var items: [Item]
    @Published var draggingItem: Item?
    @Published var dragOffset: CGSize = .zero
    
    init(items: [Item]) {
        self.items = items
    }
    
    func startDragging(at point: CGPoint) {
        draggingItem = items.first { $0.rect.contains(point) }
        if draggingItem != nil {
            dragOffset = .zero
        }
    }
    
    func updateDrag(to point: CGPoint, translation: CGSize) {
        guard let draggingItem = draggingItem else { return }
        dragOffset = translation
    }
    
    func endDragging() {
        guard let draggingItem = draggingItem else { return }
        if let index = items.firstIndex(where: { $0.id == draggingItem.id }) {
            let newX = items[index].rect.origin.x + dragOffset.width
            let newY = items[index].rect.origin.y + dragOffset.height
            items[index].rect.origin = CGPoint(x: newX, y: newY)
        }
        self.draggingItem = nil
        dragOffset = .zero
    }
}

// 메인 뷰
public struct ContentView: View {
    @StateObject private var viewModel: DragViewModel
    
    init() {
        let initialItems = [
            Item(rect: CGRect(x: 50, y: 50, width: 100, height: 100)),
            Item(rect: CGRect(x: 200, y: 200, width: 100, height: 100)),
            Item(rect: CGRect(x: 250, y: 200, width: 100, height: 100))
        ]
        _viewModel = StateObject(wrappedValue: DragViewModel(items: initialItems))
    }
    
    public var body: some View {
        ZStack {
            ForEach(viewModel.items) { item in
                Rectangle()
                    .fill(viewModel.draggingItem?.id == item.id ? Color.blue : Color.red)
                    .frame(width: item.rect.width, height: item.rect.height)
                    .position(
                        x: item.rect.midX + (viewModel.draggingItem?.id == item.id ? viewModel.dragOffset.width : 0),
                        y: item.rect.midY + (viewModel.draggingItem?.id == item.id ? viewModel.dragOffset.height : 0)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if viewModel.draggingItem == nil {
                        viewModel.startDragging(at: value.startLocation)
                    }
                    viewModel.updateDrag(to: value.location, translation: value.translation)
                }
                .onEnded { _ in
                    viewModel.endDragging()
                }
        )
    }
}

// 미리보기
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

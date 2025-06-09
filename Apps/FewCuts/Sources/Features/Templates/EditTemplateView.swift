//
//  EditTemplateView.swift
//  FewCuts
//
//  Created by 송영모 on 6/4/25.
//

import SwiftUI

@Observable
public class TemplateModel {
    var layer: Layer
    var textBlocks: [TextBlock]
    var imageBlocks: [ImageBlock]
    
    // 선택된 블록 ID
    var selectedBlockID: BlockID? = nil
    
    public init(layer: Layer, textBlocks: [TextBlock], imageBlocks: [ImageBlock]) {
        self.layer = layer
        self.textBlocks = textBlocks
        self.imageBlocks = imageBlocks
    }
    
    // MARK: - 블록 선택 관리
    func selectBlock(_ blockID: BlockID) {
        selectedBlockID = blockID
        print("🎯 블록 선택: \(blockID)")
    }
    
    func deselectBlock() {
        selectedBlockID = nil
        print("🎯 블록 선택 해제")
    }
    
    func isSelected(_ blockID: BlockID) -> Bool {
        return selectedBlockID == blockID
    }
    
    // MARK: - 바인딩 헬퍼
    func getBinding(for blockID: BlockID) -> Binding<CGRect> {
        // 텍스트 블록 확인
        if let index = textBlocks.firstIndex(where: { $0.id == blockID }) {
            return Binding(
                get: { self.textBlocks[index].rect },
                set: { self.textBlocks[index].rect = $0 }
            )
        }
        
        // 이미지 블록 확인
        if let index = imageBlocks.firstIndex(where: { $0.id == blockID }) {
            return Binding(
                get: { self.imageBlocks[index].rect },
                set: { self.imageBlocks[index].rect = $0 }
            )
        }
        
        // 기본값 (이런 일은 없어야 함)
        return .constant(CGRect.zero)
    }
    
    func getRotationBinding(for blockID: BlockID) -> Binding<Double> {
        // 텍스트 블록 확인
        if let index = textBlocks.firstIndex(where: { $0.id == blockID }) {
            return Binding(
                get: { self.textBlocks[index].rotation },
                set: { self.textBlocks[index].rotation = $0 }
            )
        }
        
        // 이미지 블록 확인  
        if let index = imageBlocks.firstIndex(where: { $0.id == blockID }) {
            return Binding(
                get: { self.imageBlocks[index].rotation },
                set: { self.imageBlocks[index].rotation = $0 }
            )
        }
        
        // 기본값
        return .constant(0)
    }
}

public struct TemplateEditor: View {
    @Bindable var model: TemplateModel
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(model.layer.color)
                    .border(.gray, width: 1)
                    .onTapGesture {
                        model.deselectBlock()
                    }
                
                // 이미지 블록들
                ForEach(model.imageBlocks) { block in
                    DraggableContainerView(
                        parentSize: model.layer.size,
                        rect: model.getBinding(for: block.id),
                        rotation: model.getRotationBinding(for: block.id),
                        isSelected: model.isSelected(block.id),
                        onTapped: { model.selectBlock(block.id) }
                    ) {
                        Rectangle()
                            .fill(.gray.opacity(0.5))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.title)
                                    .foregroundColor(.white)
                            )
                    }
                }
                
                // 텍스트 블록들  
                ForEach(model.textBlocks) { block in
                    DraggableContainerView(
                        parentSize: model.layer.size,
                        rect: model.getBinding(for: block.id),
                        rotation: model.getRotationBinding(for: block.id),
                        isSelected: model.isSelected(block.id),
                        onTapped: { model.selectBlock(block.id) }
                    ) {
                        Text(block.text)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.blue.opacity(0.3))
                    }
                }
            }
            .frame(width: model.layer.size.width, height: model.layer.size.height)
        }
    }
}

public struct EditTemplateView: View {
    @State private var model: TemplateModel
    
    public init() {
        self._model = State(initialValue: TemplateModel(
            layer: Layer(color: .red, size: CGSize(width: 400, height: 600)),
            textBlocks: [
                TextBlock(rect: CGRect(x: 50, y: 50, width: 100, height: 30), text: "Sample Text")
            ],
            imageBlocks: []
        ))
    }
    
    public var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                TemplateEditor(
                    model: model
                )
                
                HStack(spacing: 20) {
                    ToolButton(systemImageName: "swatchpalette") {
                        let sizes: [CGSize] = [
                            CGSize(width: 200, height: 400),
                            CGSize(width: 280, height: 600),
                            CGSize(width: 320, height: 700),
                            CGSize(width: 350, height: 750)
                        ]
                        model.layer.size = sizes.randomElement() ?? CGSize(width: 280, height: 600)
                        model.layer.color = [Color.black, Color.blue, Color.red, Color.green].randomElement() ?? Color.black
                    }
                    
                    ToolButton(systemImageName: "grid") {
                        
                    }
                    
                    ToolButton(systemImageName: "textformat") {
                        let newTextBlock = TextBlock(
                            rect: CGRect(x: 50, y: 50 + CGFloat(model.textBlocks.count * 40), width: 100, height: 30),
                            text: "New Text"
                        )
                        model.textBlocks.append(newTextBlock)
                    }
                    
                    ToolButton(systemImageName: "photo") {
                        let newImageBlock = ImageBlock(
                            rect: CGRect(x: 60, y: 60 + CGFloat(model.imageBlocks.count * 60), width: 120, height: 80)
                        )
                        model.imageBlocks.append(newImageBlock)
                    }
                }
                .padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

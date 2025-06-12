//
//  MultiTouchView.swift
//  FewCuts
//
//  Created by 송영모 on 6/12/25.
//

import SwiftUI
import UIKit

// MARK: - 멀티터치 이벤트 프로토콜

public protocol MultiTouchDelegate: AnyObject {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView?)
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView?)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
}

// MARK: - 멀티터치 뷰

public struct MultiTouchView: UIViewRepresentable {
    public weak var delegate: MultiTouchDelegate?
    
    public init(delegate: MultiTouchDelegate? = nil) {
        self.delegate = delegate
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(delegate: delegate)
    }
    
    public func makeUIView(context: Context) -> TouchView {
        let view = TouchView()
        view.coordinator = context.coordinator
        view.isMultipleTouchEnabled = true
        return view
    }
    
    public func updateUIView(_ uiView: TouchView, context: Context) {
        uiView.coordinator = context.coordinator
        context.coordinator.delegate = delegate
    }
}

// MARK: - 터치 감지 UIView

extension MultiTouchView {
    public class TouchView: UIView {
        weak var coordinator: Coordinator?
        
        public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            coordinator?.touchesBegan(touches, with: event, in: self)
        }
        
        public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            coordinator?.touchesMoved(touches, with: event, in: self)
        }
        
        public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            coordinator?.touchesEnded(touches, with: event)
        }
        
        public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            coordinator?.touchesCancelled(touches, with: event)
        }
    }
}

// MARK: - 코디네이터

extension MultiTouchView {
    public class Coordinator: NSObject {
        weak var delegate: MultiTouchDelegate?
        
        init(delegate: MultiTouchDelegate?) {
            self.delegate = delegate
        }
        
        func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView?) {
            delegate?.touchesBegan(touches, with: event, in: view)
        }
        
        func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView?) {
            delegate?.touchesMoved(touches, with: event, in: view)
        }
        
        func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            delegate?.touchesEnded(touches, with: event)
        }
        
        func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            delegate?.touchesCancelled(touches, with: event)
        }
    }
}

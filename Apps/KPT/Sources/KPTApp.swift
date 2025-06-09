//
//  KPTApp.swift
//  KPT
//
//  Created by 송영모 on 3/18/24.
//

import SwiftUI
import SwiftData
import DS

@main
struct KPTApp: App {
    var body: some Scene {
        WindowGroup {
            SimpleTestView()
        }
    }
}

struct SimpleTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Hero Design System Test")
                .font(.largeTitle)
                .padding()
            
            Text("DS 모듈이 성공적으로 import되었습니다!")
                .font(.title2)
                .foregroundColor(.green)
            
            Button("Test Button") {
                print("Button tapped!")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
    }
}

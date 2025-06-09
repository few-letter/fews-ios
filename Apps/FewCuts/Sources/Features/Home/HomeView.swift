//
//  HomeView.swift
//  FewCuts
//
//  Created by 송영모 on 6/4/25.
//

import SwiftUI
import ComposableArchitecture

public struct HomeView: View {
    let store: StoreOf<HomeStore>
    
    public var body: some View {
        VStack {
            Text("홈 화면")
                .font(.largeTitle)
                .padding()
            
            Text("사진 편집 기능이 Templates/EditTemplateView로 분리되었습니다!")
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
                
            Text("Components 폴더에 TemplateTools와 TemplateGrids로 나누어져 있습니다.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding()
    }
}

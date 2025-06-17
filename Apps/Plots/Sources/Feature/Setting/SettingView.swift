//
//  SettingView.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/23.
//

import SwiftUI
import ComposableArchitecture

struct SettingView: View {
    public let store: StoreOf<SettingStore>
    
    public var body: some View {
        VStack(spacing: .zero) {
            Form {
                Section {
                    DisclosureGroup("Next Update") {
                        Text("폴더, 메모 이동 기능. 폴더 이름 변경, 정렬 기능, 이미지 추가하기")
                            .font(.caption)
                    }
                    
                    DisclosureGroup("Update Notes") {
                        Text("(25년 06월 11일 작성) 오랜만에 인사드립니다. 2년만에 돌아왔습니다. 혹시 기다리신 분이 있나요? 늦어서 죄송합니다. 돈을 벌기 위해서 앱에 광고를 달 예정입니다. 그리고 댓글에 달아주신 피드백 중 '폴더 기능'을 추가하게 되었습니다. 무한 폴더 트리 구조에도 끄떡 없도록 잘 만들어보았습니다.")
                            .font(.caption)
                    }
                }
                
                Link("문의하기", destination: .init(string: "https://open.kakao.com/o/snwARoCh")!)
            }
        }
        .navigationTitle("Setting")
    }
}

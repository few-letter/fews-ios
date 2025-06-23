////
////  SettingView.swift
////  Toff
////
////  Created by 송영모 on 6/15/25.
////
//
//import SwiftUI
//import ComposableArchitecture
//
//struct SettingsView: View {
//    public let store: StoreOf<SettingsStore>
//    
//    public var body: some View {
//        VStack(spacing: .zero) {
//            Form {
//                Section {
//                    DisclosureGroup("Update Notes") {
//                        Text("(25년 06월 18일 작성) 오랜만에 인사드립니다. 1년 반 만에 돌아왔습니다. 혹시 기다리신 분이 있나요? 늦어서 죄송합니다. 돈을 벌기 위해서 앱에 광고를 달 예정입니다. 조금 더 예쁘게 만들었어요!")
//                            .font(.caption)
//                    }
//                }
//                Link("문의하기", destination: .init(string: "https://open.kakao.com/o/sMpFSoCh")!)
//            }
//        }
//        .navigationTitle("Setting")
//    }
//}

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
                Text("iCloud를 허용 해주시면. iPad, WatchOS(지원예정), MacOS(지원 예정) 에서 사용가능 합니다.")
                
                Section {
                    DisclosureGroup("TMI") {
                        Text("Plotfolio는 플롯과 포트폴리오를 합친 뜻입니다. GPT가 이름을 추천해준걸로 네이밍을 결정했습니다. 처음에는 사진을 넣는 기능을 추가할까 고민했는데, 사진은 안넣기로 결정했습니다. 글만 작성할 수 있게 만들 예정입니다. 그리고 한국어는 이곳에서 보는게 전부 입니다.")
                            .font(.subheadline)
                    }
                    
                    DisclosureGroup("Update Note") {
                        Text("다음 업데이트 예정 사항입니다. 폴더 기능 추가, 정렬 기능 추가")
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationTitle("Setting")
    }
}

#Preview {
    SettingView(store: Store(initialState: SettingStore.State()) {
        SettingStore()
    })
}

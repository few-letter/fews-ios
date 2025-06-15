//
//  SelectTickerView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

public struct SelectTickerView: View {
    public let store: StoreOf<SelectTickerStore>
    
    public var body: some View {
        NavigationView {
            mainView
                .navigationTitle("Select Ticker")
        }
    }
}

extension SelectTickerView {
    private var mainView: some View {
        VStack {
            ForEach(store.tickers) { ticker in
                tickerItem(ticker: ticker) {
                    
                }
            }
        }
    }
    
    private func tickerItem(ticker: Ticker, isSelected: Bool = false, onTap: @escaping () -> Void) -> some View {
        HStack {
            Text(ticker.name)
            Spacer()
            Text("")
        }
    }
}

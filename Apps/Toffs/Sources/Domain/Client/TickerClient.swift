//
//  TickerClient.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import ComposableArchitecture
import SwiftData

public protocol TickerClient {
    func create(ticker: Ticker) -> Ticker
    func fetches() -> [Ticker]
    func update(ticker: Ticker) -> Void
    func delete(ticker: Ticker) -> Void
}

private struct TickerClientKey: TestDependencyKey {
    static var testValue: any TickerClient = TickerClientTest()
}

extension DependencyValues {
    var tickerClient: any TickerClient {
        get { self[TickerClientKey.self] }
        set { self[TickerClientKey.self] = newValue }
    }
}

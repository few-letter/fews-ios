//
//  TradeClient.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import ComposableArchitecture
import SwiftData

public protocol TradeClient {
    func create() -> Trade
    func fetches() -> [Trade]
    func update(trade: Trade) -> Void
    func delete(trade: Trade) -> Void
}

private struct TradeClientKey: TestDependencyKey {
    static var testValue: any TradeClient = TradeClientTest()
}

extension DependencyValues {
    var tradeClient: any TradeClient {
        get { self[TradeClientKey.self] }
        set { self[TradeClientKey.self] = newValue }
    }
}

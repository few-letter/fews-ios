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
    func createOrUpdate(ticker: TickerModel) -> TickerModel
    func fetches() -> [TickerModel]
    func delete(ticker: TickerModel)
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

public struct TickerClientTest: TickerClient {
    public func createOrUpdate(ticker: TickerModel) -> TickerModel {
        return ticker
    }
    
    public func fetches() -> [TickerModel] {
        return []
    }
    
    public func delete(ticker: TickerModel) {
        // Test implementation
    }
}

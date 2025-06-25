//
//  TradeClient.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import ComposableArchitecture
import SwiftData
import UIKit

public protocol TradeClient {
    func createOrUpdate(trade: TradeModel) -> TradeModel
    func fetches(ticker: TickerModel?) -> [TradeModel]
    func delete(trade: TradeModel)
    
    // 이미지 처리 메서드
    func addImages(_ uiImages: [UIImage], to trade: TradeModel) -> TradeModel
    func removeImage(at index: Int, from trade: TradeModel) -> TradeModel
    func getUIImages(from trade: TradeModel) -> [UIImage]
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

//
//  TradeClientLive.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import SwiftData

public class TradeClientLive: TradeClient {
    private var context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
        self.context.autosaveEnabled = false
    }
    
    public func createOrUpdate(trade: TradeModel) -> TradeModel {
        do {
            let swiftDataTrade: Trade
            
            if let existingTrade = trade.trade {
                // 이미 저장된 trade가 있으면 프로퍼티 업데이트
                existingTrade.side = trade.side
                existingTrade.price = trade.price
                existingTrade.quantity = trade.quantity
                existingTrade.fee = trade.fee
                existingTrade.images = trade.images
                existingTrade.note = trade.note
                existingTrade.date = trade.date
                existingTrade.ticker = trade.ticker
                swiftDataTrade = existingTrade
            } else {
                // 새로운 trade 생성
                swiftDataTrade = trade.toSwiftDataTrade()
                context.insert(swiftDataTrade)
            }
            
            try context.save()
            
            // 저장된 SwiftData 객체로부터 TradeModel을 생성하여 반환
            return TradeModel(from: swiftDataTrade)
        } catch {
            // 에러 발생 시 원본 TradeModel 반환
            return trade
        }
    }
    
    public func fetches(ticker: Ticker?) -> [TradeModel] {
        do {
            var descriptor: FetchDescriptor<Trade>
            if let tickerID = ticker?.id {
                descriptor = .init(
                    predicate: #Predicate { trade in
                        trade.ticker?.id == tickerID
                    },
                    sortBy: [.init(\.date)]
                )
            } else {
                descriptor = .init(
                    sortBy: [.init(\.date)]
                )
            }
            let swiftDataTrades = try context.fetch(descriptor)
            
            return swiftDataTrades.map { TradeModel(from: $0) }
        } catch {
            return []
        }
    }
    
    public func delete(trade: TradeModel) {
        do {
            if let swiftDataTrade = trade.trade {
                context.delete(swiftDataTrade)
                try context.save()
            }
        } catch {
            // 에러 처리 (필요에 따라 로깅 추가)
        }
    }
}

public class TradeClientTest: TradeClient {
    public func createOrUpdate(trade: TradeModel) -> TradeModel {
        fatalError()
    }
    
    public func fetches(ticker: Ticker?) -> [TradeModel] {
        fatalError()
    }
    
    public func delete(trade: TradeModel) {
        fatalError()
    }
}

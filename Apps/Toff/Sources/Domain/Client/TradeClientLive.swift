//
//  TagClientLive.swift
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
    
    public func createOrUpdate(trade: Trade) -> Trade {
        do {
            context.insert(trade)
            try context.save()
        } catch {
            
        }
        
        return trade
    }
    
    public func fetches(ticker: Ticker?) -> [Trade] {
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
            let result = try context.fetch(descriptor)
            return result
        } catch {
            return []
        }
    }
    
    public func delete(trade: Trade) {
        do {
            context.delete(trade)
            try context.save()
        } catch {

        }
    }
}

public class TradeClientTest: TradeClient {
    public func createOrUpdate(trade: Trade) -> Trade {
        fatalError()
    }
    
    public func fetches(ticker: Ticker?) -> [Trade] {
        fatalError()
    }
    
    public func delete(trade: Trade) {
        fatalError()
    }
}

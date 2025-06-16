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
    }
    
    public func createOrUpdate(trade: Trade) -> Trade {
        do {
            context.insert(trade)
            try context.save()
        } catch {
            
        }
        
        return trade
    }
    
    public func fetches() -> [Trade] {
        do {
            let descriptor: FetchDescriptor<Trade> = .init()
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
    
    public func fetches() -> [Trade] {
        fatalError()
    }
    
    public func delete(trade: Trade) {
        fatalError()
    }
}

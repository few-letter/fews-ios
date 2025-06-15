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
    
    public func create() -> Trade {
        return .init(side: .buy, price: 0, quantity: 0, fee: 0, images: [], note: "", date: .now, ticker: nil)
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
    
    public func update(trade: Trade) {
        do {
            try context.save()
        } catch {
            print("Failed to update ticker: \(error)")
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
    public func create() -> Trade {
        fatalError()
    }
    
    public func fetches() -> [Trade] {
        fatalError()
    }
    
    public func update(trade: Trade) {
        fatalError()
    }
    
    public func delete(trade: Trade) {
        fatalError()
    }
}

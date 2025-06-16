//
//  TickerClientLive.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import SwiftData

public class TickerClientLive: TickerClient {
    private var context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public func create(ticker: Ticker) -> Ticker {
        save(ticker: ticker)
        return ticker
    }
    
    public func fetches() -> [Ticker] {
        do {
            let descriptor: FetchDescriptor<Ticker> = .init()
            let result = try context.fetch(descriptor)
            return result
        } catch {
            return []
        }
    }
    
    public func update(ticker: Ticker) {
        do {
            try context.save()
        } catch {
            print("Failed to update ticker: \(error)")
        }
    }
    
    public func delete(ticker: Ticker) {
        do {
            context.delete(ticker)
            print("delete")
            try context.save()
        } catch {
            
        }
    }
    
    private func save(ticker: Ticker) {
        do {
            context.insert(ticker)
            try context.save()
        } catch {
        }
    }
}

public class TickerClientTest: TickerClient {
    public func create(ticker: Ticker) -> Ticker {
        fatalError()
    }
    
    public func fetches() -> [Ticker] {
        fatalError()
    }
    
    public func update(ticker: Ticker) {
        fatalError()
    }
    
    public func delete(ticker: Ticker) {
        fatalError()
    }
}

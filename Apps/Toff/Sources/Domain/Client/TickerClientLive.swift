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
    
    public func create() -> Ticker {
        return .init(id: .init(), type: .stock, currency: .dollar, name: "", tags: [], createDate: .now)
    }
    
    public func fetches() -> [Ticker] {
        do {
            let descriptor: FetchDescriptor<Ticker> = .init(
                sortBy: [.init(\.createdDate)]
            )
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
            try context.save()
        } catch {
            
        }
    }
}

public class TickerClientTest: TickerClient {
    public func create() -> Ticker {
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

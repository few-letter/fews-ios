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
        self.context.autosaveEnabled = false
        
        createMockDataIfNeeded()
    }
    
    private func createMockDataIfNeeded() {
        // Mock 데이터 생성 로직이 필요한 경우 여기에 추가
    }
    
    public func createOrUpdate(ticker: TickerModel) -> TickerModel {
        do {
            let swiftDataTicker: Ticker
            
            if let existingTicker = ticker.ticker {
                // 기존 객체 업데이트 - updateSwiftData() 메서드 사용
                ticker.updateSwiftData()
                swiftDataTicker = existingTicker
            } else {
                // 새 객체 생성
                swiftDataTicker = ticker.toSwiftDataTicker()
                context.insert(swiftDataTicker)
            }
            
            try context.save()
            
            return TickerModel(from: swiftDataTicker)
        } catch {
            print("Failed to createOrUpdate ticker: \(error)")
            return ticker
        }
    }
    
    public func fetches() -> [TickerModel] {
        do {
            let descriptor: FetchDescriptor<Ticker> = .init()
            let result = try context.fetch(descriptor)
            return result.map { TickerModel(from: $0) }
        } catch {
            print("Failed to fetch tickers: \(error)")
            return []
        }
    }
    
    public func delete(ticker: TickerModel) {
        do {
            if let existingTicker = ticker.ticker {
                context.delete(existingTicker)
                try context.save()
            }
        } catch {
            print("Failed to delete ticker: \(error)")
        }
    }
}

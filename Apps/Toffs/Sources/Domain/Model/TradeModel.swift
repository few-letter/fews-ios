//
//  TradeModel.swift
//  Toff
//
//  Created by 송영모 on 6/17/25.
//

import Foundation
import UIKit

public struct TradeModel: Identifiable {
    public var id: UUID
    public var side: TradeSide
    public var price: Double
    public var quantity: Double
    public var fee: Double
    public var images: [Data]
    public var note: String
    public var date: Date
    public var ticker: Ticker?
    
    // SwiftData 객체 참조 (저장용)
    public var trade: Trade?
    
    public init(
        id: UUID = UUID(),
        side: TradeSide = .buy,
        price: Double = 0.0,
        quantity: Double = 0.0,
        fee: Double = 0.0,
        images: [Data] = [],
        note: String = "",
        date: Date = .now,
        ticker: Ticker? = nil,
        trade: Trade? = nil
    ) {
        self.id = id
        self.side = side
        self.price = price
        self.quantity = quantity
        self.fee = fee
        self.images = images
        self.note = note
        self.date = date
        self.ticker = ticker
        self.trade = trade
    }
}

// MARK: - SwiftData <-> Model Conversion Extensions
extension TradeModel {
    /// SwiftData Trade 객체로부터 TradeModel 생성
    public init(from swiftDataTrade: Trade) {
        self.id = swiftDataTrade.id
        self.side = swiftDataTrade.side
        self.price = swiftDataTrade.price
        self.quantity = swiftDataTrade.quantity
        self.fee = swiftDataTrade.fee
        self.images = swiftDataTrade.images
        self.note = swiftDataTrade.note
        self.date = swiftDataTrade.date
        self.ticker = swiftDataTrade.ticker
        self.trade = swiftDataTrade
    }
    
    /// TradeModel을 SwiftData Trade 객체로 변환
    public func toSwiftDataTrade() -> Trade {
        return Trade(
            id: self.id,
            side: self.side,
            price: self.price,
            quantity: self.quantity,
            fee: self.fee,
            images: self.images,
            note: self.note,
            date: self.date,
            ticker: self.ticker
        )
    }
}

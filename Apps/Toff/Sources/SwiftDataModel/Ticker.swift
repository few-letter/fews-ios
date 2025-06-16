//
//  Ticker.swift
//  ToolinderDomainTradeInterface
//
//  Created by 송영모 on 2023/09/08.
//

import Foundation
import SwiftData

@Model
public class Ticker {
    public var id: TickerID = TickerID()
    public var type: TickerType = TickerType.stock
    public var currency: Currency = Currency.dollar
    public var name: String = ""
    public var createdDate: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \Trade.ticker) public var trades: [Trade]? = []
    @Relationship(inverse: \Tag.tickers) public var tags: [Tag]? = []

    public init(
        id: TickerID = .init(),
        type: TickerType = .stock,
        currency: Currency = .dollar,
        name: String = "",
        tags: [Tag] = [],
        createDate: Date = .init(),
    ) {
        self.id = id
        self.type = type
        self.currency = currency
        self.name = name
        self.tags = tags
        self.createdDate = createDate
    }
}

public typealias TickerID = UUID

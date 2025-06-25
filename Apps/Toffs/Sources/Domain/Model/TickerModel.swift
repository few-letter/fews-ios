import Foundation
import SwiftData

public struct TickerModel: Identifiable, Comparable {
    public var id: TickerID
    public var type: TickerType
    public var currency: Currency
    public var name: String
    public var createdDate: Date
    
    // SwiftData 객체 참조 (저장용)
    public var ticker: Ticker?
    
    public init(
        id: TickerID = .init(),
        type: TickerType = .stock,
        currency: Currency = .dollar,
        name: String = "",
        createdDate: Date = .now,
        ticker: Ticker? = nil
    ) {
        self.id = id
        self.type = type
        self.currency = currency
        self.name = name
        self.createdDate = createdDate
        self.ticker = ticker
    }
    
    // Equatable
    public static func == (lhs: TickerModel, rhs: TickerModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Comparable
    public static func < (lhs: TickerModel, rhs: TickerModel) -> Bool {
        return lhs.createdDate < rhs.createdDate
    }
}

// MARK: - SwiftData <-> Model Conversion Extensions
extension TickerModel {
    /// SwiftData Ticker 객체로부터 TickerModel 생성
    public init(from swiftDataTicker: Ticker) {
        self.init(
            id: swiftDataTicker.id ?? .init(),
            type: swiftDataTicker.type ?? .stock,
            currency: swiftDataTicker.currency ?? .dollar,
            name: swiftDataTicker.name ?? "",
            createdDate: swiftDataTicker.createdDate ?? .now,
            ticker: swiftDataTicker
        )
    }
    
    /// TickerModel을 SwiftData Ticker 객체로 변환
    public func toSwiftDataTicker() -> Ticker {
        return Ticker(
            id: self.id,
            type: self.type,
            currency: self.currency,
            name: self.name,
            createDate: self.createdDate
        )
    }
    
    /// TickerModel의 값들로 참조하고 있는 SwiftData Ticker 객체를 업데이트
    public func updateSwiftData() {
        guard let swiftDataTicker = self.ticker else { return }
        
        swiftDataTicker.type = self.type
        swiftDataTicker.currency = self.currency
        swiftDataTicker.name = self.name
        swiftDataTicker.createdDate = self.createdDate
    }
}

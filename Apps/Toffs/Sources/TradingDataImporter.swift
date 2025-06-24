////
////  Im.swift
////  Toff
////
////  Created by 송영모 on 6/18/25.
////
//
//import Foundation
//import SwiftData
//
//public class TradingDataImporter {
//    private let tickerClient: TickerClient
//    private let tradeClient: TradeClient
//    
//    public init(tickerClient: TickerClient, tradeClient: TradeClient) {
//        self.tickerClient = tickerClient
//        self.tradeClient = tradeClient
//    }
//    
//    /// AAPL과 TSLA 시뮬레이션 데이터를 모두 가져오기
//    public func importAllTradingData() {
//        let aaplTicker = createAAPLTicker()
//        let tslaTicker = createTSLATicker()
//        
//        importAAPLTrades(ticker: aaplTicker)
//        importTSLATrades(ticker: tslaTicker)
//    }
//    
//    // MARK: - AAPL 데이터
//    private func createAAPLTicker() -> Ticker {
//        let aaplTicker = Ticker(
//            type: .stock,
//            currency: .dollar,
//            name: "AAPL",
//            createDate: Date()
//        )
//        return tickerClient.create(ticker: aaplTicker)
//    }
//    
//    private func importAAPLTrades(ticker: Ticker) {
//        let aaplTrades = [
//            // 5월 거래
//            TradeData(date: "2025-05-02", side: .buy, price: 189.45, quantity: 10),
//            TradeData(date: "2025-05-08", side: .buy, price: 192.30, quantity: 5),
//            TradeData(date: "2025-05-15", side: .sell, price: 195.80, quantity: 8),
//            TradeData(date: "2025-05-22", side: .buy, price: 188.90, quantity: 3),
//            TradeData(date: "2025-05-29", side: .sell, price: 191.25, quantity: 4),
//            
//            // 6월 거래
//            TradeData(date: "2025-06-03", side: .buy, price: 193.70, quantity: 4),
//            TradeData(date: "2025-06-05", side: .sell, price: 196.40, quantity: 5),
//            TradeData(date: "2025-06-10", side: .buy, price: 190.85, quantity: 5),
//            TradeData(date: "2025-06-12", side: .sell, price: 194.20, quantity: 6),
//            TradeData(date: "2025-06-16", side: .buy, price: 187.60, quantity: 6),
//            TradeData(date: "2025-06-17", side: .sell, price: 189.90, quantity: 3)
//        ]
//        
//        for tradeData in aaplTrades {
//            let tradeModel = TradeModel(
//                side: tradeData.side,
//                price: tradeData.price,
//                quantity: tradeData.quantity,
//                fee: 0.0, // 수수료 없음으로 설정
//                note: "AAPL 시뮬레이션 거래",
//                date: dateFromString(tradeData.date),
//                ticker: ticker
//            )
//            
//            _ = tradeClient.createOrUpdate(trade: tradeModel)
//        }
//    }
//    
//    // MARK: - TSLA 데이터
//    private func createTSLATicker() -> Ticker {
//        let tslaTicker = Ticker(
//            type: .stock,
//            currency: .dollar,
//            name: "TSLA",
//            createDate: Date()
//        )
//        return tickerClient.create(ticker: tslaTicker)
//    }
//    
//    private func importTSLATrades(ticker: Ticker) {
//        let tslaTrades = [
//            // 5월 거래
//            TradeData(date: "2025-05-03", side: .buy, price: 245.80, quantity: 8),
//            TradeData(date: "2025-05-09", side: .sell, price: 252.30, quantity: 3),
//            TradeData(date: "2025-05-16", side: .buy, price: 239.45, quantity: 5),
//            TradeData(date: "2025-05-23", side: .sell, price: 248.90, quantity: 4),
//            TradeData(date: "2025-05-30", side: .buy, price: 241.20, quantity: 2),
//            
//            // 6월 거래
//            TradeData(date: "2025-06-04", side: .sell, price: 256.70, quantity: 3),
//            TradeData(date: "2025-06-07", side: .buy, price: 249.85, quantity: 3),
//            TradeData(date: "2025-06-11", side: .sell, price: 262.40, quantity: 4),
//            TradeData(date: "2025-06-13", side: .buy, price: 258.90, quantity: 4),
//            TradeData(date: "2025-06-16", side: .sell, price: 266.15, quantity: 3),
//            TradeData(date: "2025-06-17", side: .buy, price: 261.30, quantity: 3)
//        ]
//        
//        for tradeData in tslaTrades {
//            let tradeModel = TradeModel(
//                side: tradeData.side,
//                price: tradeData.price,
//                quantity: tradeData.quantity,
//                fee: 0.0, // 수수료 없음으로 설정
//                note: "TSLA 시뮬레이션 거래",
//                date: dateFromString(tradeData.date),
//                ticker: ticker
//            )
//            
//            _ = tradeClient.createOrUpdate(trade: tradeModel)
//        }
//    }
//    
//    // MARK: - Helper Methods
//    private func dateFromString(_ dateString: String) -> Date {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        return formatter.date(from: dateString) ?? Date()
//    }
//    
//    /// 특정 ticker의 모든 거래 내역을 가져오기
//    public func getTrades(for tickerName: String) -> [TradeModel] {
//        let tickers = tickerClient.fetches()
//        guard let ticker = tickers.first(where: { $0.name == tickerName }) else {
//            return []
//        }
//        return tradeClient.fetches(ticker: ticker)
//    }
//    
//    /// 포트폴리오 요약 정보 계산
//    public func getPortfolioSummary(for tickerName: String, initialCapital: Double = 2000.0) -> PortfolioSummary {
//        let trades = getTrades(for: tickerName)
//        
//        var cashBalance = initialCapital
//        var stockHoldings = 0.0
//        var totalInvested = 0.0
//        var totalReturned = 0.0
//        
//        for trade in trades.sorted(by: { $0.date < $1.date }) {
//            let amount = trade.price * trade.quantity
//            
//            if trade.side == .buy {
//                cashBalance -= amount
//                stockHoldings += trade.quantity
//                totalInvested += amount
//            } else {
//                cashBalance += amount
//                stockHoldings -= trade.quantity
//                totalReturned += amount
//            }
//        }
//        
//        let currentStockValue = stockHoldings * (trades.last?.price ?? 0)
//        let portfolioValue = cashBalance + currentStockValue
//        let totalReturn = portfolioValue - initialCapital
//        let returnPercentage = (totalReturn / initialCapital) * 100
//        
//        return PortfolioSummary(
//            tickerName: tickerName,
//            initialCapital: initialCapital,
//            currentCash: cashBalance,
//            stockHoldings: stockHoldings,
//            currentStockValue: currentStockValue,
//            portfolioValue: portfolioValue,
//            totalReturn: totalReturn,
//            returnPercentage: returnPercentage,
//            totalTrades: trades.count
//        )
//    }
//}
//
//// MARK: - Helper Structs
//private struct TradeData {
//    let date: String
//    let side: TradeSide
//    let price: Double
//    let quantity: Double
//}
//
//public struct PortfolioSummary {
//    public let tickerName: String
//    public let initialCapital: Double
//    public let currentCash: Double
//    public let stockHoldings: Double
//    public let currentStockValue: Double
//    public let portfolioValue: Double
//    public let totalReturn: Double
//    public let returnPercentage: Double
//    public let totalTrades: Int
//    
//    public var description: String {
//        return """
//        Portfolio Summary for \(tickerName):
//        - Initial Capital: $\(String(format: "%.2f", initialCapital))
//        - Current Cash: $\(String(format: "%.2f", currentCash))
//        - Stock Holdings: \(String(format: "%.1f", stockHoldings)) shares
//        - Current Stock Value: $\(String(format: "%.2f", currentStockValue))
//        - Portfolio Value: $\(String(format: "%.2f", portfolioValue))
//        - Total Return: $\(String(format: "%.2f", totalReturn)) (\(String(format: "%.2f", returnPercentage))%)
//        - Total Trades: \(totalTrades)
//        """
//    }
//}
//
//// MARK: - Usage Example
///*
//// 사용 예시:
//let context = // SwiftData ModelContext
//let tickerClient = TickerClientLive(context: context)
//let tradeClient = TradeClientLive(context: context)
//
//let importer = TradingDataImporter(tickerClient: tickerClient, tradeClient: tradeClient)
//
//// 모든 데이터 가져오기
//importer.importAllTradingData()
//
//// 개별 포트폴리오 요약
//let aaplSummary = importer.getPortfolioSummary(for: "AAPL")
//let tslaSummary = importer.getPortfolioSummary(for: "TSLA")
//
//print(aaplSummary.description)
//print(tslaSummary.description)
//*/

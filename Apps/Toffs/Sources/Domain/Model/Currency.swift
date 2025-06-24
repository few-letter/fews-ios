//
//  Tradecurrency.swift
//  ToolinderDomainTradeInterface
//
//  Created by 송영모 on 2023/09/04.
//

import Foundation

public enum Currency: String, Codable, CaseIterable, Equatable {
    case dollar = "USD"             // 미국: 달러
    case euro = "EUR"               // 유럽: 유로
    case yen = "JPY"                // 일본: 옌
    case sterling = "GBP"           // 영국: 스털링
    case australianDollar = "AUD"   // 오스트레일리아: 오스트레일리아 달러
    case canadianDollar = "CAD"     // 캐나다: 캐나다 달러
    case franc = "CHF"              // 스위스: 프랑
    case krona = "SEK"              // 스웨덴: 크로나
    case peso = "MXN"               // 멕시코: 페소
    case newZealandDollar = "NZD"   // 뉴질랜드: 뉴질랜드 달러
    case singaporeDollar = "SGD"    // 싱가포르: 싱가포르 달러
    case hongKongDollar = "HKD"     // 홍콩: 홍콩 달러
    case krone = "NOK"              // 노르웨이: 크로네
    case won = "KRW"                // 대한민국: 원
    
    case bitcoin = "BTC"            // 비트코인
}

extension Currency {
    public var displayText: String {
        switch self {
        case .dollar:
            return "USD"
        case .euro:
            return "EUR"
        case .yen:
            return "JPY"
        case .sterling:
            return "GBP"
        case .australianDollar:
            return "AUD"
        case .canadianDollar:
            return "CAD"
        case .franc:
            return "CHF"
        case .krona:
            return "SEK"
        case .peso:
            return "MXN"
        case .newZealandDollar:
            return "NZD"
        case .singaporeDollar:
            return "SGD"
        case .hongKongDollar:
            return "HKD"
        case .krone:
            return "NOK"
        case .won:
            return "KRW"
        case .bitcoin:
            return "BTC"
        }
    }
    
    public var systemImageName: String {
        switch self {
        case .dollar:
            return "dollarsign.circle"
        case .euro:
            return "eurosign.circle"
        case .yen:
            return "yensign.circle"
        case .sterling:
            return "sterlingsign.circle"
        case .australianDollar:
            return "australsign.circle"
        case .canadianDollar:
            return "dollarsign.circle"
        case .franc:
            return "francsign.circle"
        case .krona:
            return "banknote"
        case .peso:
            return "pesosign.circle"
        case .newZealandDollar:
            return "dollarsign.circle"
        case .singaporeDollar:
            return "dollarsign.circle"
        case .hongKongDollar:
            return "dollarsign.circle"
        case .krone:
            return "banknote"
        case .won:
            return "wonsign.circle"
        case .bitcoin:
            return "bitcoinsign.circle"
        }
    }
}

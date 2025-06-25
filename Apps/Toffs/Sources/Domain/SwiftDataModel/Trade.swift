//
//  TradeEntity.swift
//  ToolinderDomainTrade
//
//  Created by 송영모 on 2023/09/04.
//

import Foundation
import SwiftData
import UIKit

@Model
public class Trade {
    public var id: UUID = UUID()
    public var side: TradeSide = TradeSide.buy
    public var price: Double = 0
    public var quantity: Double = 0
    public var fee: Double = 0
    
    /// 이미지들을 외부 저장소에 저장 (큰 바이너리 데이터를 위해)
    @Attribute(.externalStorage) public var images: [Data] = []
    
    public var note: String = ""
    public var date: Date = Date.now
    
    @Relationship public var ticker: Ticker?
    
    public init(
        id: UUID = .init(),
        side: TradeSide = .buy,
        price: Double = 0.0,
        quantity: Double = 0.0,
        fee: Double = 0.0,
        images: [Data] = [],
        note: String = "",
        date: Date = .now,
        ticker: Ticker? = nil
    ) {
        self.id = id
        self.side = side
        self.images = images
        self.price = price
        self.quantity = quantity
        self.fee = fee
        self.note = note
        self.date = date
        self.ticker = ticker
    }
}

// MARK: - Trade Image Helpers
extension Trade {
    /// UIImage 배열을 Trade에 추가
    /// - Parameter uiImages: 추가할 UIImage 배열
    func addImages(_ uiImages: [UIImage]) {
        for uiImage in uiImages {
            do {
                let pngData = try UIImage.convertToPNG(uiImage: uiImage)
                self.images.append(pngData)
            } catch {
                print("Failed to convert image to PNG: \(error)")
            }
        }
    }
    
    /// 저장된 이미지 데이터를 UIImage 배열로 변환
    /// - Returns: UIImage 배열
    func getUIImages() -> [UIImage] {
        return images.compactMap { UIImage(from: $0) }
    }
}

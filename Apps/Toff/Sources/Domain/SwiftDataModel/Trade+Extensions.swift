//
//  Trade+Extensions.swift
//  Toff
//
//  Created by 송영모 on 6/17/25.
//

import Foundation

extension Trade {
    public func copy() -> Trade {
        let newTrade = Trade(
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
        return newTrade
    }
    
    public func copyValues(from other: Trade) {
        self.side = other.side
        self.price = other.price
        self.quantity = other.quantity
        self.fee = other.fee
        self.images = other.images
        self.note = other.note
        self.date = other.date
    }

    public func validateBalance(in allTrades: [Trade]) -> String? {

        guard let ticker = ticker else { return nil }

        var snapshot = allTrades
            .filter { $0.id != self.id }
            .filter { $0.ticker?.id == ticker.id }
        
        snapshot.append(self)

        snapshot.sort {
            $0.date == $1.date ? $0.id.uuidString < $1.id.uuidString
                               : $0.date <  $1.date
        }

        var runningQty = 0.0
        let eps = 1e-8

        for tr in snapshot {
            let beforeQty = runningQty

            runningQty += (tr.side == .buy ?  tr.quantity
                                           : -tr.quantity)

            if runningQty < -eps, tr.side == .sell {
                let deficit  = abs(runningQty)
                let required = tr.quantity
                let available = beforeQty
                
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm"
                let dateStr = df.string(from: tr.date)
                
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 0
                formatter.maximumFractionDigits = 8
                formatter.numberStyle = .decimal
                
                let reqStr = formatter.string(from: NSNumber(value: required)) ?? String(required)
                let availStr = formatter.string(from: NSNumber(value: available)) ?? String(available)
                let deficitStr = formatter.string(from: NSNumber(value: deficit)) ?? String(deficit)

                return (tr.id == self.id)
                    ? """
                      Not enough holdings to execute this sell.
                      Needed \(reqStr), but only \(availStr) available (short by \(deficitStr)).
                      """
                    : """
                      This change will cause a shortfall on \(dateStr).
                      That sell needs \(reqStr), but only \(availStr) would remain (short \(deficitStr)).
                      """
            }
        }
        return nil
    }
}

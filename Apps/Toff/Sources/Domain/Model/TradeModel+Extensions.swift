//
//  Trade+Extensions.swift
//  Toff
//
//  Created by 송영모 on 6/17/25.
//

import Foundation

extension TradeModel {
    // MARK: - Balance Validation
    /// Returns **nil** if 실행 가능, 오류 메시지(String) 면 부족.
    public func validateBalance(in allTrades: [TradeModel]) -> String? {
        guard let ticker = ticker else { return nil }

        // ① 현재 티커의 모든 거래 + 나 자신 스냅샷
        var snapshot = allTrades
            .filter { $0.id != self.id }
            .filter { $0.ticker?.id == ticker.id }

        snapshot.append(self)

        // ② 정렬 :   날짜 ↑  →  같은 시각이면  Buy → Sell  →  UUID
        snapshot.sort { lhs, rhs in
            if lhs.date != rhs.date {                // 시간 우선
                return lhs.date < rhs.date
            }
            if lhs.side != rhs.side {                // 같은 시각 : 매수 먼저
                return lhs.side == .buy
            }
            return lhs.id.uuidString < rhs.id.uuidString
        }

        // ───────── 검사 시작 ─────────
        var runningQty = 0.0
        let eps = 1e-8

        // 포매터 헬퍼
        let dateFmt: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd HH:mm"
            return f
        }()
        let numFmt: NumberFormatter = {
            let f = NumberFormatter()
            f.minimumFractionDigits = 0
            f.maximumFractionDigits = 8
            f.numberStyle = .decimal
            return f
        }()
        func s(_ v: Double) -> String {
            numFmt.string(from: NSNumber(value: v)) ?? String(v)
        }

        for tr in snapshot {

            // ③ 매도 실행 *전* 보유량 확인
            if tr.side == .sell, runningQty + eps < tr.quantity {
                let deficit  = tr.quantity - runningQty
                let dateStr  = dateFmt.string(from: tr.date)

                return (tr.id == self.id)
                    ? """
                      Not enough holdings to execute this sell.
                      Needed \(s(tr.quantity)), but only \(s(runningQty)) available \
                      (short by \(s(deficit))).
                      """
                    : """
                      This change will cause a shortfall on \(dateStr).
                      That sell needs \(s(tr.quantity)), but only \(s(runningQty)) would remain \
                      (short \(s(deficit))).
                      """
            }

            // ④ 누적 (검사 후 적용)
            runningQty += (tr.side == .buy ?  tr.quantity
                                           : -tr.quantity)
        }

        return nil   // 모든 매도가 통과
    }
}

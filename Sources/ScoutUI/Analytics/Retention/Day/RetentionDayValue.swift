//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct RetentionDayValue: Identifiable {
    static let barScale = 0.5

    let day: RetentionDay
    let size: Int
    let rate: Double?
    let average: Double?
    let pending: String?

    var id: Int { day.rawValue }

    var kept: Int? {
        guard let rate else {
            return nil
        }
        return rate.kept(in: size)
    }

    var keptLabel: String? {
        kept.map { $0.formatted(.count) }
    }

    var rateLabel: String? {
        rate.map { $0.formatted(.retentionRate) }
    }

    var pendingLabel: String? {
        guard rate == nil else {
            return nil
        }
        return pending
    }

    var fraction: Double {
        min((rate ?? 0) / Self.barScale, 1)
    }

    var averageFraction: Double? {
        average.map { min($0 / Self.barScale, 1) }
    }
}

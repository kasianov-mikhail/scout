//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct ActiveUsersMetric: Identifiable {
    let kind: ActiveUsers.Kind
    let value: Int
    let delta: Double
    let series: [Int]

    var id: ActiveUsers.Kind { kind }

    var valueLabel: String {
        value.formatted(.number.locale(Locale(identifier: "en_US")))
    }

    var deltaLabel: String {
        let percent = (delta * 1000).rounded() / 10
        let format = percent == percent.rounded() ? "%+.0f%%" : "%+.1f%%"

        return String(format: format, percent)
    }
}

extension ActiveUsersMetric {
    init(kind: ActiveUsers.Kind, series: [Int]) {
        let current = series.last ?? 0
        let previous = series.dropLast().last ?? 0
        let delta = previous > 0 ? Double(current - previous) / Double(previous) : 0

        self.init(
            kind: kind,
            value: current,
            delta: delta,
            series: series
        )
    }
}

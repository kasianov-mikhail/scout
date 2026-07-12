//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension IncidentGroup where Element == Hang {
    var maxDuration: TimeInterval {
        records.map(\.duration).max() ?? 0
    }

    var averageDuration: TimeInterval {
        records.map(\.duration).reduce(0, +) / Double(records.count)
    }

    var severity: HangSeverity {
        maxDuration >= 8 ? .critical : .warning
    }

    var durationText: String {
        maxDuration < 60 ? String(format: "%.1fs", maxDuration) : "\(Int(maxDuration) / 60)m \(Int(maxDuration) % 60)s"
    }
}

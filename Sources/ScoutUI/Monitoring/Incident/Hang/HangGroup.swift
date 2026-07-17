//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension IncidentGroup where Element == Hang {
    var maxDuration: TimeInterval {
        records.map(\.duration).max() ?? 0
    }

    var averageDuration: TimeInterval {
        records.map(\.duration).reduce(0, +) / Double(records.count)
    }

    var severity: HangSeverity {
        peak.severity
    }

    var durationText: String {
        peak.durationText
    }

    // The longest hang in the group; groups always hold at least one record.
    private var peak: Hang {
        records.max { $0.duration < $1.duration } ?? representative
    }
}

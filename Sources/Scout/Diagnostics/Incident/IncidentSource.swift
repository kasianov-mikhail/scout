//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package enum IncidentSource: Equatable, Sendable {
    case inProcess
    case metricKit(windowStart: Date?)
}

private let metricKitValue = "metrickit"

extension IncidentSource {
    init(record: Record) {
        let value: String? = record["source"]

        if value == metricKitValue {
            self = .metricKit(windowStart: record["date_start"])
        } else {
            self = .inProcess
        }
    }

    func apply(to entry: IncidentEntry) {
        guard case .metricKit(let windowStart) = self else {
            return
        }
        entry.source = metricKitValue
        entry.windowStart = windowStart
    }

    func encode(into record: inout Record) {
        guard case .metricKit(let windowStart) = self else {
            return
        }
        record["source"] = metricKitValue
        record["date_start"] = windowStart
    }
}

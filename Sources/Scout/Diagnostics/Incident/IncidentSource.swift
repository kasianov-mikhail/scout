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

extension IncidentSource {
    private static let metricKitValue = "metrickit"

    // Records predate the field, so an in-process incident leaves it out and
    // a value this version doesn't know reads as in-process too.
    init(record: Record) {
        let value: String? = record["source"]

        if value == Self.metricKitValue {
            self = .metricKit(windowStart: record["date_start"])
        } else {
            self = .inProcess
        }
    }

    func encode(into record: inout Record) {
        guard case .metricKit(let windowStart) = self else {
            return
        }
        record["source"] = Self.metricKitValue
        record["date_start"] = windowStart
    }
}

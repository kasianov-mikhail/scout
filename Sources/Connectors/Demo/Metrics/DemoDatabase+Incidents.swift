//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension DemoDatabase: IncidentReader {
    func incidentIndex(recordType: String, in range: Range<Date>) async throws -> IncidentIndex? {
        let matching = records.filter { record in
            let date: Date? = record["date"]
            return record.recordType == recordType && date.map(range.contains) == true
        }

        let tallies = Dictionary(grouping: matching) { $0["fingerprint"] ?? "" }.compactMap { fingerprint, records -> IncidentTally? in
            let dates = records.compactMap { $0["date"] as Date? }

            guard !fingerprint.isEmpty, let first = dates.min() else {
                return nil
            }
            return IncidentTally(
                fingerprint: fingerprint,
                name: records[0]["name"] ?? "",
                count: records.count,
                firstHour: Calendar.utc.dateInterval(of: .hour, for: first)?.start ?? first
            )
        }

        return IncidentIndex(tallies: tallies, unkeyed: nil)
    }
}

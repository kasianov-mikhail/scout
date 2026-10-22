//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension DemoDatabase: IncidentReader {
    func incidentTallies(recordType: String, in range: Range<Date>) async throws -> [IncidentTally] {
        let matching = records.filter { record in
            let date: Date? = record["date"]
            return record.recordType == recordType && date.map(range.contains) == true
        }

        return Dictionary(grouping: matching) { $0["fingerprint"] ?? "" }.compactMap { fingerprint, records in
            let dates = records.compactMap { $0["date"] as Date? }

            guard !fingerprint.isEmpty, let first = dates.min() else {
                return nil
            }
            return IncidentTally(
                fingerprint: fingerprint,
                count: records.count,
                firstHour: Calendar.utc.dateInterval(of: .hour, for: first)?.start ?? first
            )
        }
    }
}

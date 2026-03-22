//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension Matrix where T == GridCell<Int> {
    static var sampleRecords: [CKRecord] {
        let calendar = Calendar.utc
        let today = Date().startOfDay

        return (-52...0).compactMap { weekOffset in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today) else {
                return nil
            }

            let record = CKRecord(recordType: Int.recordType)
            record["date"] = weekStart
            record["name"] = "event_name"

            for day in 1...7 {
                for hour in stride(from: 8, through: 20, by: 2) {
                    record["cell_\(day)_\(String(format: "%02d", hour))"] = Int.random(in: 1...15)
                }
            }

            return record
        }
    }
}

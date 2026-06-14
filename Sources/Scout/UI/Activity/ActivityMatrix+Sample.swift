//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

extension Matrix where T == PeriodCell<Int> {
    static var sampleRecords: [Record] {
        let calendar = Calendar.utc
        let today = Date().startOfDay

        return (-52...0).compactMap { weekOffset in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today) else {
                return nil
            }

            var record = Record(recordType: PeriodCell<Int>.recordType, id: RecordID(recordName: UUID().uuidString))
            record["date"] = weekStart
            record["name"] = "ActiveUser"

            for day in 1...7 {
                record["cell_d_\(day.leadingZero)"] = Int.random(in: 20...80)
                record["cell_w_\(day.leadingZero)"] = Int.random(in: 100...300)
                record["cell_m_\(day.leadingZero)"] = Int.random(in: 400...900)
            }

            return record
        }
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKDatabase: ActivityReader {}

extension ActivityReader {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        let query = RecordQuery(
            recordType: PeriodMatrix.self,
            filters: range.dateFilters
        )

        let matrices: [PeriodMatrix] = try await readAll(matching: query)
        return ActivityPoint.points(from: matrices)
    }
}

extension ActivityPoint {
    static func points(from matrices: [PeriodMatrix]) -> [ActivityPoint] {
        var totals: [Int64: (dau: Int, wau: Int, mau: Int)] = [:]

        for matrix in matrices {
            for cell in matrix.cells {
                let day = matrix.date.addingTimeInterval(TimeInterval(cell.day) * .day)
                let key = day.millisecondsSince1970

                switch cell.period {
                case .daily:
                    totals[key, default: (0, 0, 0)].dau += cell.value
                case .weekly:
                    totals[key, default: (0, 0, 0)].wau += cell.value
                case .monthly:
                    totals[key, default: (0, 0, 0)].mau += cell.value
                }
            }
        }

        return totals.map { date, counts in
            ActivityPoint(date: date, dau: counts.dau, wau: counts.wau, mau: counts.mau)
        }
    }
}

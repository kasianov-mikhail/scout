//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct ActivityReaderTests {
    @Test("Rebuilds the activity series from PeriodMatrix records")
    func reconstructsFromMatrices() async throws {
        let database = DatabaseStub()
        database.add(
            Matrix<PeriodCell<Int>>(
                date: date(2026, 6, 1),
                name: "ActiveUser",
                category: nil,
                baseRecord: nil,
                cells: [
                    PeriodCell(period: .daily, day: 9, value: 2),  // June 10
                    PeriodCell(period: .weekly, day: 9, value: 5),
                    PeriodCell(period: .monthly, day: 9, value: 7),
                    PeriodCell(period: .daily, day: 10, value: 1),  // June 11
                ]
            ).record
        )

        let series =
            try await database
            .activity(in: date(2026, 6, 1)..<date(2026, 7, 1))
            .sorted { $0.date < $1.date }

        #expect(series.count == 2)

        // A day's cells fold back into one point, day offsets resolving to dates.
        let tenth = try #require(series.first)
        #expect(tenth.date == ms(2026, 6, 10))
        #expect(tenth.dau == 2)
        #expect(tenth.wau == 5)
        #expect(tenth.mau == 7)

        // A day with only a daily cell reads zero for the other periods.
        let eleventh = try #require(series.last)
        #expect(eleventh.date == ms(2026, 6, 11))
        #expect(eleventh.dau == 1)
        #expect(eleventh.wau == 0)
        #expect(eleventh.mau == 0)
    }

    @Test("Reads an empty series when no matrices match")
    func reconstructsEmpty() async throws {
        let database = DatabaseStub()
        let series = try await database.activity(in: date(2026, 6, 1)..<date(2026, 7, 1))
        #expect(series.count == 0)
    }

    // MARK: - Helpers

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        DateComponents(calendar: .utc, year: year, month: month, day: day).date!
    }

    private func ms(_ year: Int, _ month: Int, _ day: Int) -> Int64 {
        Int64((date(year, month, day).timeIntervalSince1970 * 1000).rounded())
    }
}

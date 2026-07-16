//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct RetentionCohort: Identifiable, Hashable {
    static let dayOffsets = [0, 1, 3, 7, 14, 30]

    let id: Date
    let size: Int
    let retention: [Double?]

    var label: String {
        cohortDateFormatter.string(from: id)
    }
}

extension RetentionCohort {
    /// Maps a wire cohort — a week start in epoch milliseconds, an install
    /// count, and a retained count per `dayOffsets` milestone (`nil` where the
    /// milestone has not elapsed) — into display rates.
    ///
    init(date: Int64, size: Int, retained: [Int?]) {
        self.init(
            id: Date(millisecondsSince1970: date),
            size: size,
            retention: retained.map { count in
                guard let count, size > 0 else { return nil }
                return Double(count) / Double(size)
            }
        )
    }
}

let cohortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "MMM d"
    return formatter
}()

extension RetentionCohort {
    struct DayStat: Identifiable {
        let day: Int
        let average: Double
        let low: Double
        let high: Double
        var id: Int { day }
    }

    static func stats(for cohorts: [RetentionCohort]) -> [DayStat] {
        dayOffsets.enumerated().compactMap { index, day in
            let rates = cohorts.compactMap { $0.retention[index] }
            guard rates.count > 0 else { return nil }
            return DayStat(
                day: day, average: rates.reduce(0, +) / Double(rates.count), low: rates.min() ?? 0,
                high: rates.max() ?? 0)
        }
    }
}

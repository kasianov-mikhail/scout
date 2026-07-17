//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

extension RetentionCohort {
    var label: String {
        cohortDateFormatter.string(from: id)
    }
}

let cohortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "MMM d"
    return formatter
}()

extension FormatStyle where Self == FloatingPointFormatStyle<Double>.Percent {
    static var retentionRate: FloatingPointFormatStyle<Double>.Percent {
        .percent.locale(Locale(identifier: "en_US")).precision(.fractionLength(0))
    }
}

extension RetentionCohort {
    struct DayStat: Identifiable {
        let day: Int
        let average: Double
        let low: Double
        let high: Double
        var id: Int { day }
    }

    // Looks up a retention rate at a `dayOffsets` milestone; nil if `day` isn't
    // a milestone or that milestone hasn't elapsed yet.
    static func rate(_ retention: [Double?], onDay day: Int) -> Double? {
        dayOffsets.firstIndex(of: day).flatMap { retention[$0] }
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

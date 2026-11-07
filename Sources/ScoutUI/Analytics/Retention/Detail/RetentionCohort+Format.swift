//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension RetentionCohort {
    var label: String {
        DateFormatter.monthDay.string(from: id)
    }

    var weekRange: String {
        let end = id.addingDay(6)
        let startMonth = Calendar.utc.component(.month, from: id)
        let endMonth = Calendar.utc.component(.month, from: end)
        let suffix = startMonth == endMonth ? DateFormatter.day.string(from: end) : DateFormatter.monthDay.string(from: end)

        return "\(label)–\(suffix)"
    }
}

extension DateFormatter {
    static let monthDay = DateFormatter(format: "MMM d")
    static let day = DateFormatter(format: "d")
}

extension FormatStyle where Self == FloatingPointFormatStyle<Double>.Percent {
    static var retentionRate: FloatingPointFormatStyle<Double>.Percent {
        .percent.locale(Locale(identifier: "en_US")).precision(.fractionLength(0))
    }

    static var incidentRate: FloatingPointFormatStyle<Double>.Percent {
        retentionRate.precision(.fractionLength(1))
    }
}

extension FormatStyle where Self == IntegerFormatStyle<Int> {
    static var count: IntegerFormatStyle<Int> {
        .number.locale(Locale(identifier: "en_US"))
    }
}

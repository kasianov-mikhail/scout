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
        DateFormatter.cohortDay.string(from: id)
    }
}

extension DateFormatter {
    static let cohortDay = DateFormatter(format: "MMM d")
}

extension FormatStyle where Self == FloatingPointFormatStyle<Double>.Percent {
    static var retentionRate: FloatingPointFormatStyle<Double>.Percent {
        .percent.locale(Locale(identifier: "en_US")).precision(.fractionLength(0))
    }
}

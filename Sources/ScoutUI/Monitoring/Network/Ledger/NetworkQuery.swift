//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct NetworkQuery {
    var name: String?
    var bucket: SeriesBucket
    var range: Range<Date>
}

extension NetworkQuery {
    init(range: NetworkRange, name: String? = nil, detailed: Bool = false, now: Date = .now) {
        self.init(name: name, bucket: detailed ? range.detailBucket : range.bucket, range: range.range(now: now))
    }

    init(day: Date, name: String?) {
        let start = day.startOfDay
        self.init(name: name, bucket: .hour, range: start..<start.addingDay())
    }

    init(month: Date, name: String?) {
        let start = month.startOfMonth
        self.init(name: name, bucket: .day, range: start..<start.addingMonth())
    }

    init(hour: Date, name: String?) {
        let start = hour.startOfHour
        self.init(name: name, bucket: .hour, range: start..<start.adding(.hour))
    }
}

extension NetworkQuery: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.bucket.rawValue == rhs.bucket.rawValue && lhs.range == rhs.range
    }
}

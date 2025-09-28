//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct RawPointData {
    let range: ClosedRange<Date>
    let points: [ChartPoint<Int>]

    func group(by component: Calendar.Component) -> [ChartPoint<Int>] {
        var result: [ChartPoint<Int>] = []
        var date = range.lowerBound

        while date < range.upperBound {
            let next = date.adding(component)

            let count = points.filter { item in
                (date..<next).contains(item.date)
            }.reduce(0) {
                $0 + $1.count
            }

            result.append(ChartPoint(date: date, count: count))
            date = next
        }

        return result
    }
}

extension RawPointData: CustomStringConvertible {
    var description: String {
        let formatter = ISO8601DateFormatter()
        let start = formatter.string(from: range.lowerBound)
        let end = formatter.string(from: range.upperBound)

        let previewCount = min(points.total, 5)
        let preview = points.prefix(previewCount).map(\.description).joined(separator: ", ")
        let more = points.total > previewCount ? ", …" : ""

        return "RawPointData(range: \(start)...\(end), points: \(points.total) [\(preview)\(more)])"
    }
}

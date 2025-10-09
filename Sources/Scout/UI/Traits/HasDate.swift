//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol HasDate {
    var date: Date { get }
    init(date: Date)
}

extension Array where Element: HasDate {
    func segment(in range: ClosedRange<Date>) -> [Element] {
        var points = filter {
            range.contains($0.date)
        }

        if !points.isEmpty {
            points.append(Element(date: range.lowerBound))
            points.append(Element(date: range.upperBound))
        }

        return points
    }
}

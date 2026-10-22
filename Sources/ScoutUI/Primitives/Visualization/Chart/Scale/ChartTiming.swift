//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

protocol ChartTiming {
    var unit: Calendar.Component { get }
    var tickValues: [Date]? { get }
}

func binRange(of date: Date, unit: Calendar.Component) -> Range<Date> {
    let interval = Calendar.utc.dateInterval(of: unit, for: date)!
    return interval.start..<interval.end
}

extension ChartTiming {
    func tickDates(for segment: [ChartPoint<some ChartNumeric>]) -> [Date] {
        if let values = tickValues {
            return values
        }
        let starts = segment.map { binRange(of: $0.date, unit: unit).lowerBound }.sorted()
        let step = max(1, (starts.count + 3) / 4)
        return stride(from: 0, to: starts.count, by: step).map { starts[$0] }
    }
}

extension ChartExtent: ChartTiming {
    var unit: Calendar.Component {
        period.pointComponent
    }

    var tickValues: [Date]? {
        if case .month = period.rangeComponent {
            [-28, -21, -14, -7].map(domain.upperBound.addingDay)
        } else {
            nil
        }
    }
}

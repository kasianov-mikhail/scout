//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct ChartTimeScaleTests {
    @Test("The previous range is the window right before the current one")
    func previousRange() {
        let scale = makeScale(day: 8)

        #expect(scale.initialRange == Date(year: 2026, month: 6, day: 7)..<Date(year: 2026, month: 6, day: 8))
        #expect(scale.previousRange == Date(year: 2026, month: 6, day: 6)..<Date(year: 2026, month: 6, day: 7))
    }

    @Test("The two ranges meet without a gap or an overlap")
    func rangesAreAdjacent() {
        let scale = makeScale(day: 8)

        #expect(scale.previousRange.upperBound == scale.initialRange.lowerBound)
    }

    @Test("Every period pairs its window with an equally long one before it", arguments: Period.allCases)
    func everyPeriodHasAPreviousRange(period: Period) {
        #expect(period.previousRange.upperBound == period.initialRange.lowerBound)
        #expect(period.previousRange.lowerBound < period.previousRange.upperBound)
    }

    private func makeScale(day: Int) -> DayScale {
        DayScale(horizonDate: Date(year: 2026, month: 6, day: day))
    }
}

private struct DayScale: ChartTimeScale {
    let horizonDate: Date

    var id: Date { horizonDate }
    var rangeComponent: Calendar.Component { .day }
    var pointComponent: Calendar.Component { .hour }
}

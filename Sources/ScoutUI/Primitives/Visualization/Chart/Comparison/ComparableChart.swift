//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ComparableChart<T: ChartNumeric, S: ChartTimeScale>: View {
    let segment: [ChartPoint<T>]
    let points: [ChartPoint<T>]
    let extent: ChartExtent<S>
    let color: Color
    let isComparing: Bool
    var markers: [Date] = []

    var body: some View {
        if isComparing {
            ComparisonChartView(
                segment: segment,
                reference: extent.referenceSegment(from: points, alignedTo: segment),
                timing: extent,
                color: color
            )
        } else {
            ChartView(segment: segment, timing: extent, markers: markers)
                .foregroundStyle(color)
        }
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// Chart row that switches between the plain bar chart and the comparison
/// overlay; pairs with `ComparisonToggle` driving `isComparing`.
///
/// `points` is the full data set the reference segment is bucketed from,
/// while `segment` is the already-computed current-window slice of it.
///
struct ComparableChart<T: ChartNumeric, S: ChartTimeScale>: View {
    let segment: [ChartPoint<T>]
    let points: [ChartPoint<T>]
    let extent: ChartExtent<S>
    let color: Color
    let isComparing: Bool

    var body: some View {
        if isComparing {
            ComparisonChartView(
                segment: segment,
                reference: extent.referenceSegment(from: points, alignedTo: segment),
                timing: extent,
                color: color
            )
        } else {
            ChartView(segment: segment, timing: extent)
                .foregroundStyle(color)
        }
    }
}

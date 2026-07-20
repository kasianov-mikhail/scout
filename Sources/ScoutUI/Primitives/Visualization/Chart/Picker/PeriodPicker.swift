//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct PeriodPicker<T: PickerCompatible & ChartTimeScale & CaseIterable>: View {
    @Binding var extent: ChartExtent<T>

    let periods: [T]

    var body: some View {
        SegmentStrip(
            selection: $extent.period,
            values: periods,
            distribution: .justified,
            title: title
        )
        .padding(.horizontal)
    }

    private func title(period: T) -> String {
        var title = period.shortTitle
        if period == extent.period && extent.isRightEnabled {
            title += "*"
        }
        return title
    }
}

#Preview {
    PeriodPicker(
        extent: .constant(ChartExtent(period: Period.today)),
        periods: Period.allCases
    )
}

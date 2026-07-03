//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct PeriodPicker<T: PickerCompatible & ChartTimeScale>: View {
    @Binding var extent: ChartExtent<T>

    let periods: [T]

    var body: some View {
        HStack(spacing: 20) {
            SegmentStrip(
                selection: $extent.period,
                values: periods,
                tint: nil,
                title: title
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

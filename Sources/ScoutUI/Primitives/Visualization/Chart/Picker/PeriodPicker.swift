//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct PeriodPicker<T: ChartTimeScale & CaseIterable>: View {
    @Binding var extent: ChartExtent<T>

    let title: (T) -> String

    var body: some View {
        SegmentStrip(
            selection: $extent.period,
            distribution: .justified,
            title: marked
        )
    }

    private func marked(period: T) -> String {
        var marked = title(period)
        if period == extent.period && extent.isRightEnabled {
            marked += "*"
        }
        return marked
    }
}

#Preview {
    PeriodPicker(
        extent: .constant(ChartExtent(period: Period.today)),
        title: \.shortTitle
    )
}

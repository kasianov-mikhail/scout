//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RetentionWeekRow: View {
    let week: RetentionWeek
    let maxInstalls: Int
    let showsDivider: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text(verbatim: week.label)
                .font(.system(size: 13))
                .frame(width: 52, alignment: .leading)

            RetentionBar(week: week, maxInstalls: maxInstalls)

            RetentionValueLabel(kept: week.keptLabel, rate: week.rateLabel, pending: week.pendingLabel)
                .frame(width: 76, alignment: .trailing)
        }
        .frame(height: 40)
        .overlay(alignment: .bottom) {
            if showsDivider {
                DashedLine()
            }
        }
    }
}

#Preview {
    InsetList {
        ForEach([RetentionWeek].samples) { week in
            RetentionWeekRow(week: week, maxInstalls: [RetentionWeek].samples.maxInstalls, showsDivider: week.kept != nil)
                .frame(minHeight: 44)
        }
    }
}

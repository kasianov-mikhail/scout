//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct FilterPeriodView: View {
    @ObservedObject var draft: FilterDraft

    var body: some View {
        FilterSection(title: "Period") {
            FilterBox {
                HStack(spacing: 0) {
                    let periods = FilterPeriod.presets

                    ForEach(periods) { period in
                        FilterSegment(
                            title: period.title,
                            isSelected: draft.period == period,
                            ink: draft.period == period ? .blue : .primary,
                            fill: Color.blue.opacity(0.12),
                            showsDivider: period != periods.last
                        ) {
                            draft.period = period
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    FilterPeriodView(draft: FilterDraft(query: .constant(EventQuery())))
        .padding(16)
}

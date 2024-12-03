//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct PeriodPicker: View {
    @Binding private var period: StatPeriod
    let accent: Bool

    init(period: Binding<StatPeriod>, accent: Bool = false) {
        self._period = period
        self.accent = accent
    }

    var body: some View {
        Picker("", selection: $period) {
            ForEach(StatPeriod.allCases) { period in
                if period == self.period, accent {
                    Text(period.shortTitle + "*")
                } else {
                    Text(period.shortTitle)
                }
            }
        }
        .padding(.horizontal)
        .pickerStyle(.segmented)
    }
}

extension StatPeriod {

    /// A short title for each statistical period.
    fileprivate var shortTitle: String {
        switch self {
        case .today:
            "T"
        case .yesterday:
            "Y"
        case .week:
            "7"
        case .month:
            "30"
        case .year:
            "365"
        }
    }
}

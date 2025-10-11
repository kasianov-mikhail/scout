//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct PeriodPicker<T: PickerCompatible & ChartTimeScale>: View {
    @Binding var extent: ChartExtent<T>

    let periods: [T]

    var body: some View {
        Picker("", selection: $extent.period) {
            ForEach(periods) { period in
                if period == extent.period, extent.isAccented {
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

extension ChartExtent {
    fileprivate var isAccented: Bool {
        isRightEnabled
    }
}

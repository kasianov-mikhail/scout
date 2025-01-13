//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct PeriodPicker: View {
    @ObservedObject var model: StatModel

    let periods: [Period]

    var body: some View {
        Picker("", selection: $model.period) {
            ForEach(periods) { period in
                if period == model.period, model.isAccented {
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

extension StatModel {

    /// A Boolean value that indicates whether the current period is accented.
    /// Accenting is used to highlight the current period in the picker using an asterisk.
    ///
    fileprivate var isAccented: Bool {
        isRightEnabled
    }
}

extension Period {

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

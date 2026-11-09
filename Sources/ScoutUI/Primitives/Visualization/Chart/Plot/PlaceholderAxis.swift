//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

extension View {
    @ViewBuilder
    func placeholderAxis(active: Bool) -> some View {
        if active {
            chartYScale(domain: 0...1).chartYAxis {
                AxisMarks(values: [0, 1]) { _ in
                    AxisGridLine()
                }
            }
        } else {
            self
        }
    }
}

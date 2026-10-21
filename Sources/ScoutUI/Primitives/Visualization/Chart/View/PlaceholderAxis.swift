//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

extension View {
    // Swift Charts drops the Y axis when there is no data, so an empty chart
    // loses the top and bottom lines that frame it when data is present. Pin a
    // fixed 0...1 domain and draw gridlines at both bounds to keep that framing.
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

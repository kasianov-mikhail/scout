//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Charts
import SwiftUI

struct StatusBar: View {
    let status: StatusBreakdown

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Chart(status.segments) { segment in
                BarMark(
                    x: .value("Count", segment.count),
                    y: .value("Row", "status")
                )
                .foregroundStyle(segment.color)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 18)
            .clipShape(Capsule())

            HStack(spacing: 16) {
                ForEach(status.segments) { segment in
                    HStack(spacing: 5) {
                        Circle().fill(segment.color).frame(width: 7, height: 7)
                        Text(verbatim: segment.label + " " + segment.count.plain)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

#Preview("StatusBar") {
    StatusBar(status: .sample(success: 8_140, redirect: 210, clientError: 96, serverError: 18))
        .padding(.horizontal)
}

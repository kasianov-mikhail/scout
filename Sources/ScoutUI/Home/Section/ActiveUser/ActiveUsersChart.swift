//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

struct ActiveUsersChart: View {
    let metric: ActiveUsersMetric
    let start: Date
    let end: Date

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(metric.series.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(index == metric.series.indices.last ? Color.green : Color(.systemGray4))
                        .frame(maxWidth: .infinity)
                        .frame(height: height(for: metric.series[index]))
                }
            }
            .frame(height: 72)

            HStack {
                Text(verbatim: DateFormatter.monthDay.string(from: start))

                Spacer()

                Text(verbatim: DateFormatter.monthDay.string(from: middle))

                Spacer()

                Text(verbatim: "today")
            }
            .font(.system(size: 10))
            .foregroundStyle(Color(.systemGray))
        }
    }

    private var middle: Date {
        start.addingTimeInterval(end.timeIntervalSince(start) / 2)
    }

    private func height(for value: Int) -> CGFloat {
        guard let maximum = metric.series.max(), maximum > 0 else {
            return 0
        }
        return CGFloat(value) / CGFloat(maximum) * 72
    }
}

#Preview {
    ActiveUsersChart(metric: ActiveUsers.sample.metrics[0], start: ActiveUsers.sample.start, end: ActiveUsers.sample.end)
        .padding()
}

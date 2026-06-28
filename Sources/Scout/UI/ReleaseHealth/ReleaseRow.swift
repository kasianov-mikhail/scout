//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

private func ringTrim(_ value: Double) -> Double {
    max(0, min(1, (value - 0.95) / 0.05))
}

private struct CompactRing: View {
    let value: Double
    var size: CGFloat = 16
    var lineWidth: CGFloat = 2

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: ringTrim(value))
                .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .padding(.horizontal, 4)
    }
}

struct ReleaseRow: View {
    let release: ReleaseHealth

    var body: some View {
        Row {
            CompactRing(value: release.crashFreeSessions)

            Text(verbatim: release.version)
                .font(.system(size: 17))
                .monospacedDigit()

            Spacer()

            MiniChart(
                series: MiniChartSeries(values: release.trend),
                color: ReleaseHealth.healthColor(release.crashFreeSessions)
            )

            Text(verbatim: ReleaseHealth.percent(release.crashFreeSessions))
                .font(.system(size: 15))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .frame(minWidth: 80, alignment: .trailing)
                .padding(.leading, 8)
        } destination: {
            VersionDetailView(release: release)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            ForEach(ReleaseHealth.sample) { release in
                ReleaseRow(release: release)
            }
        }
        .listStyle(.plain)
    }
}

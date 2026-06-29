//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

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

            ReleasePercent(text: ReleaseHealth.percent(release.crashFreeSessions))
        } destination: {
            VersionDetailView(release: release)
        }
    }
}

private struct CompactRing: View {
    let value: Double

    var body: some View {
        ZStack {
            let ringTrim = max(0, min(1, (value - 0.95) / 0.05))

            Circle()
                .stroke(Color(.systemGray5), lineWidth: 2)
            Circle()
                .trim(from: 0, to: ringTrim)
                .stroke(.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 16, height: 16)
        .padding(.horizontal, 4)
    }
}

struct ReleaseRowPlaceholder: View {
    var body: some View {
        HStack {
            CompactRing(value: 0.95)

            Text(verbatim: "3.2.1")
                .font(.system(size: 17))
                .monospacedDigit()

            Spacer()

            MiniChart(series: nil, color: .gray)

            ReleasePercent(text: "100.00%")
        }
        .redacted(reason: .placeholder)
        .trailingRowSeparator()
    }
}

private struct ReleasePercent: View {
    let text: String

    var body: some View {
        Text(verbatim: text)
            .font(.system(size: 15))
            .monospacedDigit()
            .foregroundStyle(.primary)
            .frame(minWidth: 80, alignment: .trailing)
            .padding(.leading, 8)
    }
}

#Preview {
    NavigationStack {
        List {
            ForEach(ReleaseHealth.samples) { release in
                ReleaseRow(release: release)
            }
            ReleaseRowPlaceholder()
            ReleaseRowPlaceholder()
        }
        .listStyle(.plain)
        .navigationTitle(en: "Releases")
    }
}

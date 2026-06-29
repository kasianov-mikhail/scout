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
            CompactRing(rate: release.freeSessions)

            Text(verbatim: release.id)
                .font(.system(size: 17))
                .monospacedDigit()

            Spacer()

            MiniChart(
                series: MiniChartSeries(values: release.trend),
                color: release.freeSessions.color
            )

            ReleasePercent(text: release.freeSessions.formatted)
        } destination: {
            VersionDetailView(release: release)
        }
    }
}

private struct CompactRing: View {
    let rate: Stability

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 2)
            Circle()
                .trim(from: 0, to: rate.ringTrim)
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
            CompactRing(rate: 0.95)

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

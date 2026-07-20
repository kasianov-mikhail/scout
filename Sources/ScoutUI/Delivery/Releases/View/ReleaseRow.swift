//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ReleaseRow: View {
    let release: ReleaseHealth

    var body: some View {
        Row {
            CompactRing(release: release)

            Text(verbatim: release.id)
                .font(.body)
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
    let adoption: Adoption
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 2)
            Circle()
                .trim(from: 0, to: adoption.value)
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 16, height: 16)
        .padding(.horizontal, 4)
    }
}

extension CompactRing {
    init(release: ReleaseHealth) {
        self.init(adoption: release.adoption, color: release.freeSessions.color)
    }
}

struct ReleaseRowPlaceholder: View {
    var body: some View {
        HStack {
            CompactRing(adoption: 1.0, color: .gray)

            Text(verbatim: "3.2.1")
                .font(.subheadline)
                .monospacedDigit()

            Spacer()

            ReleasePercent(text: "1000.00%")
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
            .font(.subheadline)
            .monospacedDigit()
            .foregroundStyle(.primary)
            .frame(minWidth: 80, alignment: .trailing)
            .padding(.leading, 8)
    }
}

#Preview {
    NavigationStack {
        List {
            ForEach([ReleaseHealth].samples) { release in
                ReleaseRow(release: release)
            }
            ReleaseRowPlaceholder()
            ReleaseRowPlaceholder()
        }
        .listStyle(.plain)
        .navigationTitle(en: "Releases")
    }
}

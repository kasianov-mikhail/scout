//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Scout
import SwiftUI

struct ExitsSection: View {
    let summary: ExitSummary

    @ViewBuilder
    var body: some View {
        if let clean = summary.clean {
            Header(title: "Exits")

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 28) {
                    Readout(title: "Clean exits", stability: clean)
                    Readout(title: "Exits", value: summary.total.compact)
                    Spacer()
                }

                if !summary.abnormal.isEmpty {
                    ExitShareBar(shares: summary.abnormal)
                        .padding(.bottom, 16)
                }
            }
            .listRowSeparator(.hidden, edges: .bottom)

            if !summary.abnormal.isEmpty {
                ForEach(summary.abnormal) { share in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(share.reason.color)
                            .frame(width: 8, height: 8)

                        Text(verbatim: share.reason.title)
                            .font(.callout)

                        Spacer()

                        Text(verbatim: share.formatted)
                            .font(.callout)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

private struct ExitShareBar: View {
    let shares: [ExitShare]

    var body: some View {
        Chart(shares) { share in
            BarMark(x: .value("Exits", share.count), stacking: .normalized)
                .foregroundStyle(share.reason.color)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .frame(height: 8)
        .clipShape(Capsule())
    }
}

#Preview {
    InsetList {
        ExitsSection(summary: [ReleaseHealth].samples[0].exits)
    }
}

#Preview("Only clean exits") {
    InsetList {
        ExitsSection(summary: ExitSummary(counts: [.normal: 1200, .memoryPressure: 300]))
    }
}

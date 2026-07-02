//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct FunnelLegendRow: View {
    let metric: FunnelStepMetrics
    var color: Color = .blue

    var body: some View {
        HStack(spacing: 10) {
            FunnelStepIndex(index: metric.index, color: color)
            Text(verbatim: metric.step.name)
                .font(.footnote)
                .monospaced()
            Spacer()
            if let conversion = metric.conversionFromPrevious {
                Text(verbatim: "→ \(conversion.funnelPercent)")
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.red.opacity(0.8))
            }
            Text(verbatim: metric.step.count.formatted())
                .font(.footnote.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(minWidth: 56, alignment: .trailing)
        }
    }
}

struct FunnelStepIndex: View {
    let index: Int
    var color: Color = .blue

    var body: some View {
        Text(verbatim: "\(index + 1)")
            .font(.caption2.weight(.bold))
            .monospacedDigit()
            .foregroundStyle(color)
            .frame(width: 18, height: 18)
            .background(color.opacity(0.13), in: Circle())
    }
}

#Preview("Funnel legend") {
    List {
        ForEach(FunnelStep.samples.metrics) { metric in
            FunnelLegendRow(metric: metric)
        }
    }
    .listStyle(.plain)
}

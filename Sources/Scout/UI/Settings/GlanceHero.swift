//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct GlanceSummary {
    let reachable: Int
    let total: Int
    let averageLatency: Int?

    init(backends: [BackendHealth]) {
        reachable = backends.filter { $0.status == .reachable }.count
        total = backends.count
        let latencies = backends.compactMap(\.latency)
        averageLatency = latencies.count > 0 ? latencies.reduce(0, +) / latencies.count : nil
    }

    var allOperational: Bool { reachable == total }

    var title: String {
        allOperational ? "All Systems Operational" : "\(reachable) of \(total) Backends Reachable"
    }

    var detail: String {
        let count = total == 1 ? "1 backend" : "\(total) backends"
        return averageLatency.map { "\(count) · \($0) ms average latency" } ?? count
    }

    var color: Color { allOperational ? .green : .orange }

    var icon: String { allOperational ? "checkmark.seal.fill" : "exclamationmark.triangle.fill" }
}

struct GlanceHero: View {
    let summary: GlanceSummary

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: summary.icon)
                .font(.system(size: 42))
                .foregroundStyle(summary.color)

            Text(verbatim: summary.title)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(verbatim: summary.detail)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [summary.color.opacity(0.18), summary.color.opacity(0.04)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
    }
}

#Preview("Operational") {
    GlanceHero(summary: GlanceSummary(backends: Array(BackendHealth.samples.prefix(2))))
        .padding()
}

#Preview("Degraded") {
    GlanceHero(summary: GlanceSummary(backends: BackendHealth.samples))
        .padding()
}

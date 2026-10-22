//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct GlanceSummary {
    let reachable: Int
    let pending: Int
    let total: Int
    let averageLatency: Int?

    init(backends: [BackendHealth]) {
        reachable = backends.filter { $0.status == .reachable }.count
        pending = backends.filter { $0.status == nil && $0.probe != nil }.count
        total = backends.count
        let latencies = backends.compactMap(\.latency)
        averageLatency = latencies.isEmpty ? nil : latencies.reduce(0, +) / latencies.count
    }

    var state: GlanceState {
        if total == 0 {
            .empty
        } else if pending > 0 {
            .checking
        } else if reachable == total {
            .operational
        } else {
            .degraded
        }
    }

    var title: String {
        switch state {
        case .empty:
            "No Backends Configured"
        case .checking:
            "Checking Backends…"
        case .operational:
            "All Systems Operational"
        case .degraded:
            "\(reachable) of \(total) Backends Reachable"
        }
    }

    var detail: String {
        let count = ExportFormat.counted(total, .backend)
        return switch state {
        case .empty:
            "Pass at least one backend to scoutHome"
        case .checking:
            "\(count) · \(pending) pending"
        case .operational, .degraded:
            averageLatency.map { "\(count) · \($0) ms average latency" } ?? count
        }
    }
}

struct GlanceHero: View {
    let summary: GlanceSummary

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: summary.state.icon)
                .font(.system(size: 42))
                .foregroundStyle(summary.state.color)

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
                        colors: [summary.state.color.opacity(0.18), summary.state.color.opacity(0.04)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
    }
}

#Preview("Operational") {
    GlanceHero(summary: GlanceSummary(backends: Array([BackendHealth].samples.prefix(2))))
        .padding()
}

#Preview("Degraded") {
    GlanceHero(summary: GlanceSummary(backends: .samples))
        .padding()
}

#Preview("Checking") {
    GlanceHero(summary: GlanceSummary(backends: [Backend].samples.map(BackendHealth.init)))
        .padding()
}

#Preview("No Backends") {
    GlanceHero(summary: GlanceSummary(backends: []))
        .padding()
}

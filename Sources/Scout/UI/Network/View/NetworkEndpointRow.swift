//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct NetworkEndpointLink: View {
    let endpoint: NetworkEndpoint
    let report: NetworkReport
    let range: Range<Date>

    var body: some View {
        Row {
            NetworkEndpointRow(endpoint: endpoint)
        } destination: {
            NetworkEndpointDetailView(
                endpoint: endpoint,
                distribution: report.distributions[endpoint.name],
                statuses: report.statuses[endpoint.name],
                range: range
            )
            .monospacedNavigationTitle(en: endpoint.path)
        }
    }
}

struct NetworkEndpointRow: View {
    let endpoint: NetworkEndpoint

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(endpoint.successRate?.color ?? .gray)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: endpoint.name)
                    .font(.system(size: 15, weight: .medium))
                Text(verbatim: endpoint.requests.plain + " req · " + (endpoint.successRate?.formatted ?? "—"))
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(verbatim: endpoint.p99?.duration ?? "—")
                    .font(.system(size: 15, weight: .semibold))
                    .monospacedDigit()
                Text(verbatim: "P99")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.gray)
            }
        }
        .frame(height: 44)
    }
}

#Preview("NetworkEndpointRow") {
    List(NetworkEndpoint.samples) { endpoint in
        NetworkEndpointRow(endpoint: endpoint)
    }
    .listStyle(.plain)
}

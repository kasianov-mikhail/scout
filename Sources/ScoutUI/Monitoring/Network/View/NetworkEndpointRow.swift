//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct NetworkEndpointRow: View {
    let endpoint: NetworkEndpoint
    let report: NetworkReport
    let range: Range<Date>

    var body: some View {
        Row {
            HStack(spacing: 12) {
                Circle()
                    .fill(endpoint.successRate?.color ?? .gray)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: endpoint.name)
                        .font(.subheadline.weight(.medium))
                    Text(verbatim: endpoint.requests.plain + " req · " + (endpoint.successRate?.formatted ?? "—"))
                        .font(.caption)
                        .foregroundStyle(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(verbatim: endpoint.p99?.duration ?? "—")
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                    Text(verbatim: "P99")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.gray)
                }
            }
            .frame(height: 70)
        } destination: {
            NetworkEndpointDetailView(endpoint: endpoint, report: report, range: range)
        }
    }
}

#Preview("NetworkEndpointRow") {
    let report = NetworkReport.sample
    let range = Period.today.initialRange

    NavigationStack {
        PlainList {
            ForEach(report.endpoints(in: range)) { endpoint in
                NetworkEndpointRow(endpoint: endpoint, report: report, range: range)
            }
        }
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct NetworkEndpointsView: View {
    let report: NetworkReport
    let range: Range<Date>

    var body: some View {
        let endpoints = report.endpoints(in: range)
        let breakdown = report.summary(in: range)
        let worstP99 = endpoints.compactMap(\.p99).max()

        InsetList {
            HStack(spacing: 28) {
                Readout(
                    title: "Requests",
                    value: breakdown.total.plain,
                    color: .primary
                )
                Readout(
                    title: "Success",
                    value: breakdown.successRate.formatted,
                    color: breakdown.successRate.color
                )
                Readout(
                    title: "Worst P99",
                    value: worstP99?.duration ?? "—",
                    color: .orange
                )
                Spacer()
            }

            Header(title: "Endpoints")
            ForEach(endpoints) { endpoint in
                NetworkEndpointRow(
                    endpoint: endpoint,
                    report: report,
                    range: range
                )
                .frame(height: 70)
            }
        }
        .navigationTitle(en: "Endpoints")
    }
}

#Preview("NetworkEndpointsView") {
    NavigationStack {
        NetworkEndpointsView(report: .sample, range: Period.today.initialRange)
    }
}

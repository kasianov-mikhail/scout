//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct EndpointSearchDetail: View {
    let name: String

    @StateObject var provider = NetworkProvider()

    var body: some View {
        ProviderView(provider: provider) { report in
            let range = Period.today.initialRange

            if let endpoint = report.endpoints(in: range).first(where: { $0.name == name }) {
                NetworkEndpointDetailView(endpoint: endpoint, report: report, range: range)
            } else {
                Placeholder(
                    text: "No requests",
                    systemImage: "network",
                    description: "No requests have been recorded for this endpoint today"
                )
            }
        }
    }
}

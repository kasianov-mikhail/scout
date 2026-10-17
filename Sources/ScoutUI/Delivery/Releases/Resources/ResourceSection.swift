//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ResourceSection: View {
    let summary: ResourceSummary
    let records: [ResourceException]
    let showAll: () -> Void

    @ViewBuilder
    var body: some View {
        if summary.total > 0 || !records.isEmpty {
            IncidentTrendSection(records: records) {
                if !records.isEmpty {
                    AllButton(action: showAll)
                }
            }

            HStack(spacing: 28) {
                ForEach(summary.readouts) { readout in
                    Readout(title: readout.title, value: "\(readout.value)")
                }
                Spacer()
            }
        }
    }
}

#Preview {
    InsetList {
        ResourceSection(summary: .sample, records: .samples) {}
    }
}

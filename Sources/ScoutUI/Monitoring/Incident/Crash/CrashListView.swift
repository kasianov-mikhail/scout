//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct CrashListView: View {
    @StateObject var provider = IncidentTilesProvider<Crash>()

    var body: some View {
        IncidentList(
            provider: provider,
            placeholder: Placeholder(
                text: "No crashes",
                systemImage: "checkmark.shield",
                description: "No crash reports in this period"
            )
        ) { tally in
            IncidentGroupLoader(tally: tally) { occurrences in
                CrashGroupDetailView(occurrences: occurrences)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CrashListView(provider: .init(.success(IncidentTile<Crash>.samples)))
    }
}

#Preview("Empty State") {
    NavigationStack {
        CrashListView(provider: .init(.success([])))
    }
}

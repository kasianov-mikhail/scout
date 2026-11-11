//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HangListView: View {
    @StateObject var provider = IncidentTilesProvider<Hang>()

    var body: some View {
        IncidentList(
            provider: provider,
            placeholder: Placeholder(
                text: "No hangs",
                systemImage: "checkmark.shield",
                description: "No unresponsive main threads in this period"
            )
        ) { tally in
            IncidentGroupLoader(tally: tally) { occurrences in
                HangGroupDetailView(occurrences: occurrences)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HangListView(provider: .init(.success(IncidentTile<Hang>.samples)))
    }
    .environmentObject(Tint())
}

#Preview("Empty State") {
    NavigationStack {
        HangListView(provider: .init(.success([])))
    }
    .environmentObject(Tint())
}

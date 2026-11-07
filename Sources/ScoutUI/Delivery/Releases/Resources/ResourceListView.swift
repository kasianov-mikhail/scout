//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ResourceListView: View {
    @StateObject var provider = IncidentTilesProvider<ResourceException>()

    var body: some View {
        IncidentList(
            provider: provider,
            placeholder: Placeholder(
                text: "No resource exceptions",
                systemImage: "checkmark.shield",
                description: "Resource exceptions appear once your app reports them"
            )
        ) { tally in
            IncidentGroupLoader(tally: tally) { occurrences in
                ResourceGroupDetailView(occurrences: occurrences)
            }
        }
        .navigationTint(IncidentKind.resource.color)
    }
}

#Preview {
    NavigationStack {
        ResourceListView(provider: .init(.success(IncidentTile<ResourceException>.samples)))
    }
    .environmentObject(Tint())
}

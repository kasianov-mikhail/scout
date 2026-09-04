//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HangListView: View {
    @StateObject var provider = IncidentProvider<Hang>()

    var body: some View {
        IncidentList(
            provider: provider,
            placeholder: Placeholder(
                text: "No hangs",
                systemImage: "checkmark.shield",
                description: "No unresponsive main thread has been recorded"
            )
        ) { group in
            HangRow(group: group)
        }
    }
}

#Preview {
    NavigationStack {
        HangListView(provider: .init(.samples))
    }
    .environmentObject(Tint())
}

#Preview("Empty State") {
    NavigationStack {
        Placeholder(
            text: "No hangs",
            systemImage: "checkmark.shield",
            description: "No unresponsive main thread has been recorded"
        )
        .navigationTitle(en: "Hangs")
    }
}

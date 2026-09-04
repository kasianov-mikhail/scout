//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct CrashListView: View {
    @StateObject var provider = IncidentProvider<Crash>()

    var body: some View {
        IncidentList(
            provider: provider,
            placeholder: Placeholder(
                text: "No crashes",
                systemImage: "checkmark.shield",
                description: "No crash reports have been recorded"
            )
        ) { group in
            IncidentRow(group: group) { group in
                CrashGroupDetailView(group: group)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CrashListView(provider: .init(.samples))
    }
}

#Preview("Empty State") {
    NavigationStack {
        Placeholder(
            text: "No crashes",
            systemImage: "checkmark.shield",
            description: "No crash reports have been recorded"
        )
        .navigationTitle(en: "Crashes")
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

struct HangRow: View {
    let group: IncidentGroup<Hang>

    var body: some View {
        IncidentRow(
            group: group,
            accent: (group.severity.systemImage, group.severity.color)
        ) { group in
            HangGroupDetailView(group: group)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            ForEach(IncidentGroup.groups(from: [Hang].samples)) { group in
                HangRow(group: group)
            }
        }
        .listStyle(.plain)
        .navigationTitle(en: "Hangs")
    }
    .environmentObject(Tint())
}

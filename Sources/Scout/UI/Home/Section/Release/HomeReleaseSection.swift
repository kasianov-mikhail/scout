//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeReleaseSection: View {
    @Environment(\.database) var database

    @ObservedObject var provider: ReleaseHealthProvider
    @Binding var showReleaseHealth: Bool

    var body: some View {
        Header(title: "Releases") {
            Button {
                showReleaseHealth = true
            } label: {
                Text(verbatim: "All".uppercased())
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
        .task {
            await provider.fetchIfNeeded(in: database)
        }

        ForEach((provider.releases ?? []).prefix(3)) { release in
            ReleaseRow(release: release)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            HomeReleaseSection(provider: .fixture(), showReleaseHealth: .constant(false))
        }
        .listStyle(.plain)
    }
}

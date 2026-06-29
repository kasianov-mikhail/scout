//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReleaseHealthView: View {
    @Environment(\.database) var database

    @StateObject private var provider: ReleaseHealthProvider

    init(provider: ReleaseHealthProvider = ReleaseHealthProvider()) {
        self._provider = StateObject(wrappedValue: provider)
    }

    var body: some View {
        Group {
            if let releases = provider.releases {
                if releases.isEmpty {
                    Placeholder(
                        text: "No releases",
                        systemImage: "shippingbox",
                        description: "Release health appears once your app reports versions"
                    )
                } else {
                    List {
                        ForEach(releases) { release in
                            ReleaseRow(release: release)
                        }
                    }
                    .listStyle(.plain)
                }
            } else {
                ProgressView().frame(maxHeight: .infinity)
            }
        }
        .navigationTitle(en: "Releases")
        .task {
            await provider.fetchIfNeeded(in: database)
        }
    }
}

#Preview {
    NavigationStack {
        ReleaseHealthView(provider: .fixture())
    }
}

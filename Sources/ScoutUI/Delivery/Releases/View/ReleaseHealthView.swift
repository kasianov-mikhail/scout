//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ReleaseHealthView: View {
    @StateObject var provider = ReleaseHealthProvider()

    var body: some View {
        ProviderView(provider: provider) { releases in
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
        }
        .navigationTitle(en: "Releases")
    }
}

#Preview {
    let provider = ReleaseHealthProvider()
    provider.result = .success(.samples)

    return NavigationStack {
        ReleaseHealthView(provider: provider)
    }
}

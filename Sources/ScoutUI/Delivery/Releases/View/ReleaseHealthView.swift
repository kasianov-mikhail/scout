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
                InsetList {
                    ForEach(releases) { release in
                        ReleaseRow(release: release)
                    }
                }
            }
        }
        .navigationTitle(en: "Releases")
    }
}

#Preview {
    NavigationStack {
        ReleaseHealthView(provider: .init().holding(.samples))
    }
}

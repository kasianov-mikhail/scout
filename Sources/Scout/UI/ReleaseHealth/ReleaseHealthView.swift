//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReleaseHealthView: View {
    let releases = ReleaseHealth.sample

    var body: some View {
        List {
            Header(title: "Releases")

            ForEach(releases) { release in
                ReleaseRow(release: release)
            }
        }
        .listStyle(.plain)
        .navigationTitle(en: "Release Health")
    }
}

#Preview {
    NavigationStack {
        ReleaseHealthView()
    }
}

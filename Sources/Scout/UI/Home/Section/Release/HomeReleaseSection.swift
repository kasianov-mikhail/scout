//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeReleaseSection: View {
    @State private var showReleaseHealth = false

    var body: some View {
        Header(title: "Release Health") {
            Button {
                showReleaseHealth = true
            } label: {
                Text(verbatim: "All".uppercased())
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
        .navigationDestination(isPresented: $showReleaseHealth) {
            ReleaseHealthView()
        }

        ForEach(ReleaseHealth.sample.prefix(3)) { release in
            ReleaseRow(release: release)
        }
    }
}

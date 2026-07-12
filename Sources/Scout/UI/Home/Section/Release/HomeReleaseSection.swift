//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeReleaseSection: View {
    @ObservedObject var provider: ReleaseHealthProvider
    @Binding var showReleaseHealth: Bool

    var body: some View {
        Header(title: "Releases") {
            if let releases = try? provider.result?.get(), releases.count > 0 {
                AllButton { showReleaseHealth = true }
            }
        }

        switch provider.result {
        case .success(let releases) where releases.count > 0:
            ForEach(releases.prefix(3)) { release in
                ReleaseRow(release: release)
            }

        case .success:
            Text(verbatim: "No results")
                .placeholderTextStyle()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .listRowSeparator(.hidden)

        default:
            ForEach(0..<3, id: \.self) { _ in
                ReleaseRowPlaceholder()
            }
        }
    }
}

#Preview {
    let provider = ReleaseHealthProvider()
    provider.result = .success(.samples)

    return NavigationStack {
        List {
            HomeReleaseSection(provider: provider, showReleaseHealth: .constant(false))
            HomeReleaseSection(provider: ReleaseHealthProvider(releases: []), showReleaseHealth: .constant(false))
        }
        .listStyle(.plain)
    }
}

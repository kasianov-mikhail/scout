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
                if let releases = provider.releases, releases.count > 0 {
                    Text(verbatim: "All".uppercased())
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.blue)
                }
            }
            .buttonStyle(.plain)
        }
        .task {
            await provider.fetchIfNeeded(in: database)
        }

        if case .failure(let error) = provider.result {
            ErrorView(description: Text(verbatim: error.localizedDescription)) {
                Task { await provider.fetchAgain(in: database) }
            }
            .listRowSeparator(.hidden)
        } else if let releases = provider.releases {
            if releases.count > 0 {
                ForEach(releases.prefix(3)) { release in
                    ReleaseRow(release: release)
                }
            } else {
                Text(verbatim: "No results")
                    .placeholderTextStyle()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .listRowSeparator(.hidden)
            }
        } else {
            ForEach(0..<3, id: \.self) { _ in
                ReleaseRowPlaceholder()
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            HomeReleaseSection(provider: .fixture(), showReleaseHealth: .constant(false))
            HomeReleaseSection(provider: ReleaseHealthProvider(releases: []), showReleaseHealth: .constant(false))
        }
        .listStyle(.plain)
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ReleaseHealthView: View {
    @Environment(\.database) private var database

    @StateObject var provider = ReleaseHealthProvider()

    var body: some View {
        Group {
            switch provider.result {
            case nil:
                ReleaseHealthViewPlaceholder()
                    .transition(.opacity)
            case .success(let releases):
                if releases.isEmpty {
                    Placeholder(
                        text: "No releases",
                        systemImage: "shippingbox",
                        description: "Release health appears once your app reports versions"
                    )
                } else {
                    content(releases: releases)
                        .transition(.opacity)
                }
            case .failure(let error):
                ErrorView(description: Text(error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .navigationTitle(en: "Releases")
        .inlineNavigationTitle()
        .fetchTask([provider])
    }

    private func content(releases: [ReleaseHealth]) -> some View {
        let adoption = ReleaseAdoption(releases: releases)

        return List {
            ReleaseAdoptionHeader(adoption: adoption)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            ForEach(releases) { release in
                ReleaseRow(release: release, showsSeparator: release.id != releases.last?.id)
                    .listRowInsets(.sideInsets)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ReleaseHealthView(provider: .init(.success(.samples)))
    }
}

#Preview("Loading") {
    NavigationStack {
        ReleaseHealthView(provider: .init())
    }
}

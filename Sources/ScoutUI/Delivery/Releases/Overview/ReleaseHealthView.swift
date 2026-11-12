//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ReleaseHealthView: View {
    @ObservedObject var provider: ReleaseHealthProvider

    @Environment(\.database) private var database

    var body: some View {
        Group {
            switch provider.result {
            case nil:
                ReleaseHealthViewPlaceholder()
                    .transition(.opacity)
            case .success(let releases):
                content(releases: releases)
                    .transition(.opacity)
            case .failure(let error):
                ErrorView(description: Text(error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .loadingInk(isLoading: provider.isLoading)
        .fetchTask([provider])
        .navigationTitle(en: "Releases")
        .inlineNavigationTitle()
    }

    @ViewBuilder
    private func content(releases: [ReleaseHealth]) -> some View {
        if releases.isEmpty {
            Placeholder(
                text: "No releases",
                systemImage: "shippingbox",
                description: "Release health appears once your app reports versions"
            )
        } else {
            InsetList {
                ReleaseSummary(adoption: ReleaseAdoption(releases: releases))

                ForEach(Array(releases.enumerated()), id: \.element.id) { index, release in
                    ReleaseRow(release: release, isLast: index == releases.count - 1)
                }
            }
        }
    }
}

private struct ReleaseSummary: View {
    let adoption: ReleaseAdoption

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(verbatim: adoption.headline)
                    .font(.system(size: 28, weight: .bold))

                Text(verbatim: "of sessions")
                    .font(.weight450(size: 13))
                    .foregroundStyle(Color(.systemGray))
            }

            AdoptionBar(
                versions: adoption.versions,
                height: 32,
                labelSize: 11,
                labelWeight: .bold,
                labelInset: 6
            )
            .padding(.top, 12)

            AdoptionLegend(squareSize: 8, squareColor: nil)
                .padding(.top, 8)
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}

#Preview("Releases") {
    NavigationStack {
        ReleaseHealthView(provider: .init(.success(.samples)))
    }
}

#Preview("Loading") {
    NavigationStack {
        ReleaseHealthView(provider: ReleaseHealthProvider())
    }
}

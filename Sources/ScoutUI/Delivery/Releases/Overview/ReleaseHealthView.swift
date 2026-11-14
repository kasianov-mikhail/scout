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
            if let error = provider.error {
                ErrorView(description: Text(error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            } else if case .success(let releases) = provider.result, releases.isEmpty {
                Placeholder(
                    text: "No releases",
                    systemImage: "shippingbox",
                    description: "Release health appears once your app reports versions"
                )
            } else {
                ScrollView {
                    if case .success(let releases) = provider.result {
                        content(releases: releases)
                            .transition(.opacity)
                    } else {
                        ReleaseHealthViewPlaceholder()
                            .transition(.opacity)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .loadingInk(isLoading: provider.isLoading)
        .fetchTask([provider])
        .navigationTitle(en: "Releases")
        .inlineNavigationTitle()
    }

    private func content(releases: [ReleaseHealth]) -> some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ReleaseSummary(adoption: ReleaseAdoption(releases: releases))

            ForEach(Array(releases.enumerated()), id: \.element.id) { index, release in
                ReleaseRow(release: release, isLast: index == releases.count - 1)
            }
        }
        .padding(.horizontal, .gutter)
    }
}

private struct ReleaseSummary: View {
    let adoption: ReleaseAdoption

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: .space8) {
                Text(verbatim: adoption.headline)
                    .font(.scoutNumberL)

                Text(verbatim: "of sessions")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            }

            AdoptionBar(
                versions: adoption.versions,
                height: 32,
                labelSize: 10,
                labelWeight: .semibold,
                labelInset: 6
            )
            .padding(.top, .space12)

            AdoptionLegend(squareSize: 8, squareColor: nil)
                .padding(.top, .space8)
        }
        .padding(.vertical, .space12)
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

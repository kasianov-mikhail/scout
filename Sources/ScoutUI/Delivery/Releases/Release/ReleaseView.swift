//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ReleaseView: View {
    let release: ReleaseHealth

    @Environment(\.database) private var database
    @StateObject var provider: VersionTrendProvider

    init(release: ReleaseHealth, provider: VersionTrendProvider? = nil) {
        self.release = release
        self._provider = StateObject(wrappedValue: provider ?? VersionTrendProvider(version: release.id))
    }

    var body: some View {
        Group {
            if let error = provider.error {
                ErrorView(description: Text(error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            } else {
                ScrollView {
                    if case .success(let trend) = provider.result {
                        content(detail: ReleaseDetail(release: release, trend: trend, now: Date()))
                            .transition(.opacity)
                    } else {
                        Placeholder(version: release.id)
                            .transition(.opacity)
                    }
                }
                .scrollIndicators(.hidden)
                .disabledBounce()
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .loadingInk(isLoading: provider.isLoading)
        .fetchTask([provider])
        .navigationTitle(en: "Release")
        .inlineNavigationTitle(divider: nil)
        .toolbarBackground(provider.isLoading ? Color.surfaceGrey : release.freeSessions.level.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func content(detail: ReleaseDetail) -> some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ReleaseHero(detail: detail)
                .padding(.horizontal, -16)

            ReleaseGrid(detail: detail)
                .padding(.horizontal, -16)

            hangRate(detail.hangRate)
        }
        .padding(.horizontal, .gutter)
    }

    private func hangRate(_ value: ReleaseHangRate) -> some View {
        HStack(spacing: .space8) {
            Text(verbatim: "Hang rate")
                .font(.scoutRow)

            Spacer()

            HStack(spacing: 0) {
                Text(verbatim: value.value)

                if let change = value.change {
                    Text(verbatim: " · \(change)")
                }
            }
            .font(.scoutValueStrong)
            .foregroundStyle(value.color)
        }
        .frame(height: .rowRegular)
    }
}

#Preview {
    NavigationStack {
        ReleaseView(
            release: [ReleaseHealth].samples[0],
            provider: .init(.success(.sample), version: "3.2.0")
        )
    }
    .environmentObject(Tint())
}

#Preview("Loading") {
    NavigationStack {
        ReleaseView(release: [ReleaseHealth].samples[0], provider: .init(version: "3.2.0"))
    }
    .environmentObject(Tint())
}

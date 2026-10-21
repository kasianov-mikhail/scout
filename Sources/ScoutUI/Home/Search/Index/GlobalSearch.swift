//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func globalSearch(releases: ReleaseHealthProvider) -> some View {
        modifier(GlobalSearchModifier(releases: releases))
    }
}

private struct GlobalSearchModifier: ViewModifier {
    @ObservedObject var releases: ReleaseHealthProvider

    @State private var query = ""
    @State private var hasStartedLoading = false

    @StateObject private var names = SearchSeriesProvider()
    @StateObject private var devices = DevicesProvider()
    @StateObject private var crashes = IncidentGroupsProvider<Crash>()
    @StateObject private var hangs = IncidentGroupsProvider<Hang>()

    @Environment(\.database) private var database

    private var providers: [any Provider] {
        [names, devices, releases, crashes, hangs]
    }

    private var hasQuery: Bool {
        !query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func body(content: Content) -> some View {
        Group {
            if hasQuery {
                GlobalSearchList(
                    query: query,
                    index: index,
                    isLoading: providers.contains(where: \.isLoading),
                    error: providers.compactMap(\.error).first
                ) {
                    await providers.fetchIfFailed(in: database)
                }
            } else {
                content
            }
        }
        .searchable(text: $query, placement: .navigationBar, prompt: Text(verbatim: "Search"))
        .autocorrectionDisabled(true)
        .onChange(of: hasQuery) { hasQuery in
            if hasQuery && !hasStartedLoading {
                hasStartedLoading = true
                Task {
                    await providers.fetchIfNeeded(in: database)
                }
            }
        }
    }

    private var index: GlobalSearchIndex {
        GlobalSearchIndex(
            series: names.output ?? [],
            devices: devices.output ?? [],
            releases: releases.output ?? [],
            crashes: crashes.output ?? [],
            hangs: hangs.output ?? []
        )
    }
}

extension Provider {
    fileprivate var output: Output? {
        switch result {
        case .success(let output)?:
            output
        case .failure?, nil:
            nil
        }
    }
}

@MainActor
extension Sequence where Element == any Provider {
    func fetchIfNeeded(in database: DatabaseReader) async {
        await concurrentForEach { provider in
            await provider.fetchIfNeeded(in: database)
        }
    }

    func fetchIfFailed(in database: DatabaseReader) async {
        await concurrentForEach { provider in
            await provider.fetchIfFailed(in: database)
        }
    }
}

extension SearchFieldPlacement {
    fileprivate static var navigationBar: SearchFieldPlacement {
        #if os(iOS)
            .navigationBarDrawer(displayMode: .always)
        #else
            .automatic
        #endif
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func globalSearch() -> some View {
        modifier(GlobalSearchModifier())
    }
}

private struct GlobalSearchModifier: ViewModifier {
    enum LoadState {
        case loading
        case ready(GlobalSearchIndex)
        case failed(Error)
    }

    @State private var query = ""

    @StateObject private var names = SearchSeriesProvider()
    @StateObject private var devices = DevicesProvider()
    @StateObject private var releases = ReleaseHealthProvider()
    @StateObject private var crashes = IncidentGroupsProvider<Crash>()
    @StateObject private var hangs = IncidentGroupsProvider<Hang>()

    @Environment(\.database) private var database

    private var providers: [any Provider] {
        [names, devices, releases, crashes, hangs]
    }

    func body(content: Content) -> some View {
        Group {
            if query.trimmingCharacters(in: .whitespaces).isEmpty {
                content
            } else {
                results
            }
        }
        .searchable(text: $query, placement: .navigationBar, prompt: Text(verbatim: "Search"))
        .autocorrectionDisabled(true)
        .onChange(of: query) { text in
            if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                Task {
                    await providers.fetchIfNeeded(in: database)
                }
            }
        }
    }

    @ViewBuilder private var results: some View {
        switch state {
        case .ready(let index):
            GlobalSearchList(query: query, index: index)
        case .loading:
            RingIndicator().frame(maxHeight: .infinity)
        case .failed(let error):
            ErrorView(description: Text(verbatim: error.localizedDescription)) {
                await providers.fetchIfFailed(in: database)
            }
        }
    }

    private var state: LoadState {
        do {
            guard let index = try index else {
                return .loading
            }
            return .ready(index)
        } catch {
            return .failed(error)
        }
    }

    private var index: GlobalSearchIndex? {
        get throws {
            try GlobalSearchIndex(
                series: names.result?.get(),
                devices: devices.result?.get().summaries,
                releases: releases.result?.get(),
                crashes: crashes.result?.get(),
                hangs: hangs.result?.get()
            )
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

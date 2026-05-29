//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Timeline: View {
    let deviceID: UUID

    @Environment(\.database) var database
    @StateObject private var provider = TimelineProvider()

    var body: some View {
        Group {
            switch provider.result {
            case .idle, .loading:
                ProgressView().frame(maxHeight: .infinity)
            case .failure(let error):
                ErrorView(description: Text(verbatim: error.localizedDescription), retry: load)
            case .loaded(let rail):
                TimelineList(rail: rail, onLoadMore: loadMore)
            case .paging(let rail):
                TimelineList(rail: rail, isPaging: true)
            case .exhausted(let rail):
                TimelineList(rail: rail)
            }
        }
        .navigationTitle(en: "Multi-Rail")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await provider.start(deviceID: deviceID, in: database)
        }
    }

    private func load() {
        Task { await provider.start(deviceID: deviceID, in: database) }
    }

    private func loadMore() async {
        await provider.loadMore(in: database)
    }
}

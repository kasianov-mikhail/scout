//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RailPagination: View {
    @ObservedObject var lane: RailLane
    @Binding var result: Result<Rail, Error>?

    @Environment(\.database) var database

    var body: some View {
        if lane.isLoading {
            ProgressView().frame(height: 72).frame(maxWidth: .infinity)
        } else if lane.pendingInstalls.isEmpty {
            EmptyView()
        } else {
            PaginationFooter(action: loadMore)
        }
    }

    private func loadMore() async {
        do {
            let (sessions, events) = try await lane.loadMore(in: database)
            guard case .success(let rail) = result else {
                return
            }
            result = .success(rail.merged(sessions: sessions, events: events))
        } catch {
            result = .failure(error)
        }
    }
}

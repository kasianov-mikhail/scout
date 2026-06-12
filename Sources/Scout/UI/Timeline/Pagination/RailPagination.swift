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
    @Environment(\.scrollViewport) var viewport
    @Environment(\.isScrollSettled) var isSettled

    var body: some View {
        if lane.pendingInstalls.isEmpty {
            EmptyView()
        } else if lane.isLoading {
            ProgressView().frame(height: 72).frame(maxWidth: .infinity)
        } else {
            Color.clear.frame(height: 1).background {
                GeometryReader { geo in
                    let frame = geo.frame(in: .global)

                    Color.clear
                        .onAppear { loadIfVisible(frame) }
                        .onChange(of: frame.minY) { _ in loadIfVisible(frame) }
                        .onChange(of: isSettled) { _ in loadIfVisible(frame) }
                }
            }
        }
    }

    private func loadIfVisible(_ frame: CGRect) {
        let visible = frame.maxY > viewport.minY && frame.minY < viewport.maxY

        guard isSettled, visible, !lane.isLoading else {
            return
        }

        lane.isLoading = true
        Task { await loadMore() }
    }

    private func loadMore() async {
        // A reload may have replaced the result since this footer scheduled
        // the load; bail out before consuming a chunk the new timeline needs.
        guard case .success = result else {
            lane.isLoading = false
            return
        }

        do {
            let (sessions, events) = try await lane.loadMore(in: database)
            guard case .success(let rail) = result else {
                return
            }
            result = .success(rail.merged(sessions: sessions, events: events))
        } catch is CancellationError {
            // The lane was reset while this load was in flight; drop it, and
            // release the spinner `loadIfVisible` raised for this load.
            lane.isLoading = false
        } catch {
            result = .failure(error)
        }
    }
}

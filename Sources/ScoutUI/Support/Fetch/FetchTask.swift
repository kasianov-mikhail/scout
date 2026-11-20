//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
protocol Refreshable {
    func fetchLatest(in database: DatabaseReader) async
    func fetchAgain(in database: DatabaseReader) async
    func fetchNewer(in database: DatabaseReader) async
    func refresh(in database: DatabaseReader) async
}

extension Refreshable {
    func fetchNewer(in database: DatabaseReader) async {
        await fetchLatest(in: database)
    }

    func refresh(in database: DatabaseReader) async {
        await fetchLatest(in: database)
    }
}

extension View {
    func fetchTask(_ providers: [any Refreshable]) -> some View {
        modifier(FetchTaskModifier(providers: providers))
    }
}

private struct FetchTaskModifier: ViewModifier {
    let providers: [any Refreshable]

    @Environment(\.database) private var database
    @Environment(\.changes) private var changes
    @Environment(\.pollInterval) private var pollInterval
    @Environment(\.scenePhase) private var scenePhase

    @State private var isFetching = false

    func body(content: Content) -> some View {
        content
            .task {
                await providers.fetchLatest(in: database)
            }
            .task(id: changes.generation) {
                guard changes.generation > 0 else {
                    return
                }
                await refresh()
            }
            .task(id: PollKey(interval: pollInterval, phase: scenePhase)) {
                await poll()
            }
    }

    private func poll() async {
        #if os(iOS)
            guard !providers.isEmpty, pollInterval > .zero, scenePhase == .active else {
                return
            }

            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: pollInterval)
                } catch {
                    return
                }
                guard !Task.isCancelled else {
                    return
                }
                await refreshNewer()
            }
        #endif
    }

    private func refresh() async {
        guard !isFetching else {
            return
        }

        isFetching = true
        defer { isFetching = false }

        await providers.refresh(in: database)
    }

    private func refreshNewer() async {
        guard !isFetching else {
            return
        }

        isFetching = true
        defer { isFetching = false }

        await providers.fetchNewer(in: database)
    }
}

private struct PollKey: Equatable {
    let interval: Duration
    let phase: ScenePhase
}

extension [any Refreshable] {
    @MainActor
    func fetchLatest(in database: DatabaseReader) async {
        await concurrentForEach { provider in
            await provider.fetchLatest(in: database)
        }
    }

    @MainActor
    func fetchAgain(in database: DatabaseReader) async {
        await concurrentForEach { provider in
            await provider.fetchAgain(in: database)
        }
    }

    @MainActor
    func refresh(in database: DatabaseReader) async {
        await concurrentForEach { provider in
            await provider.refresh(in: database)
        }
    }

    @MainActor
    func fetchNewer(in database: DatabaseReader) async {
        await concurrentForEach { provider in
            await provider.fetchNewer(in: database)
        }
    }
}

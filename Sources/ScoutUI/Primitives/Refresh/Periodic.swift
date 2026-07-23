//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
protocol Periodic {
    @discardableResult
    func fetchLatest(in database: DatabaseReader) async -> Bool
}

extension View {
    func periodRefresh(provider: any Periodic) -> some View {
        periodRefresh(providers: [provider])
    }

    func periodRefresh(providers: [any Periodic]) -> some View {
        modifier(PeriodRefreshModifier(first: providers, later: []))
    }

    func periodRefresh(first: [any Periodic], later: [any Periodic]) -> some View {
        modifier(PeriodRefreshModifier(first: first, later: later))
    }
}

private struct PeriodRefreshModifier: ViewModifier {
    @Environment(\.database) private var database

    let first: [any Periodic]
    let later: [any Periodic]

    func body(content: Content) -> some View {
        content.foregroundTask {
            let first = actions(for: first)
            let later = actions(for: later)

            await first.fetch()
            await later.fetch()

            await RefreshSchedule(first + later).rotate()
        }
    }

    private func actions(for providers: [any Periodic]) -> [RefreshAction] {
        providers.map { provider in
            { await provider.fetchLatest(in: database) }
        }
    }
}

extension [RefreshAction] {
    fileprivate func fetch() async {
        await withTaskGroup(of: Void.self) { group in
            for refresh in self {
                group.addTask {
                    _ = await refresh()
                }
            }
        }
    }
}

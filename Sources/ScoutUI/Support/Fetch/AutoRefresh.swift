//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    func autoRefresh<ID: Equatable>(id: ID, every interval: Duration = .seconds(12), refresh: @escaping @MainActor () async -> Void) -> some View {
        modifier(AutoRefresh(id: id, interval: interval, refresh: refresh))
    }
}

@MainActor
func autoRefreshLoop(every interval: Duration, refresh: @MainActor () async -> Void) async {
    while !Task.isCancelled {
        await refresh()
        do {
            try await Task.sleep(for: interval)
        } catch {
            return
        }
    }
}

private struct AutoRefresh<ID: Equatable>: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase

    let id: ID
    let interval: Duration
    let refresh: @MainActor () async -> Void

    func body(content: Content) -> some View {
        content.task(id: Key(id: id, isActive: scenePhase == .active)) {
            guard scenePhase == .active else {
                return
            }
            await autoRefreshLoop(every: interval, refresh: refresh)
        }
    }

    private struct Key: Equatable {
        let id: ID
        let isActive: Bool
    }
}

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
}

extension View {
    func fetchTask(_ providers: [any Refreshable]) -> some View {
        modifier(FetchTaskModifier(first: providers, later: []))
    }

    func fetchTask(first: [any Refreshable], later: [any Refreshable]) -> some View {
        modifier(FetchTaskModifier(first: first, later: later))
    }
}

private struct FetchTaskModifier: ViewModifier {
    @Environment(\.database) private var database

    let first: [any Refreshable]
    let later: [any Refreshable]

    func body(content: Content) -> some View {
        content.task {
            await actions(for: first).fetch()
            await actions(for: later).fetch()
        }
    }

    private func actions(for providers: [any Refreshable]) -> [FetchAction] {
        providers.map { provider in
            { await provider.fetchLatest(in: database) }
        }
    }
}

private typealias FetchAction = @MainActor () async -> Void

extension [FetchAction] {
    fileprivate func fetch() async {
        await withTaskGroup(of: Void.self) { group in
            for action in self {
                group.addTask {
                    await action()
                }
            }
        }
    }
}

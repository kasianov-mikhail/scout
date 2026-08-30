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
            await first.fetchLatest(in: database)
            await later.fetchLatest(in: database)
        }
    }
}

extension [any Refreshable] {
    @MainActor
    func fetchLatest(in database: DatabaseReader) async {
        await fetch { provider in
            await provider.fetchLatest(in: database)
        }
    }

    @MainActor
    func fetchAgain(in database: DatabaseReader) async {
        await fetch { provider in
            await provider.fetchAgain(in: database)
        }
    }

    @MainActor
    private func fetch(_ operation: @escaping @MainActor (any Refreshable) async -> Void) async {
        let actions: [@MainActor () async -> Void] = map { provider in
            { await operation(provider) }
        }

        await withTaskGroup(of: Void.self) { group in
            for action in actions {
                group.addTask {
                    await action()
                }
            }
        }
    }
}

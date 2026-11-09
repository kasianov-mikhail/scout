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
        modifier(FetchTaskModifier(providers: providers))
    }
}

private struct FetchTaskModifier: ViewModifier {
    @Environment(\.database) private var database

    let providers: [any Refreshable]

    func body(content: Content) -> some View {
        content.task {
            await providers.fetchLatest(in: database)
        }
    }
}

extension [any Refreshable] {
    @MainActor
    func fetchLatest(in database: DatabaseReader) async {
        await concurrentForEach { provider in
            await provider.fetchLatest(in: database)
        }
    }
}

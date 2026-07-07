//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SessionEventList: View {
    let sessionID: UUID

    @StateObject var provider = EventProvider()
    @Environment(\.database) var database

    var body: some View {
        EventList(provider: provider)
            .task {
                await provider.fetchIfNeeded(for: query, in: database)
            }
            .navigationTitle(en: "Session Events")
    }

    private var query: Event.Query {
        var query = Event.Query()
        query.sessionID = sessionID
        return query
    }
}

#Preview {
    let provider = EventProvider()
    provider.events = .samples

    return NavigationStack {
        SessionEventList(sessionID: UUID(), provider: provider)
    }
}

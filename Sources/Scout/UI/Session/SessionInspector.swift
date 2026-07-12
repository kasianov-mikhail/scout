//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SessionInspector: View {
    let sessionID: UUID
    let deviceID: UUID?

    @StateObject private var events: EventProvider
    @StateObject private var info: SessionInfoProvider
    @Environment(\.database) var database

    init(sessionID: UUID, deviceID: UUID?, events: EventProvider? = nil, info: SessionInfoProvider? = nil) {
        self.sessionID = sessionID
        self.deviceID = deviceID
        self._events = StateObject(wrappedValue: events ?? EventProvider())
        self._info = StateObject(wrappedValue: info ?? SessionInfoProvider(sessionID: sessionID, deviceID: deviceID))
    }

    var body: some View {
        EventList(provider: events) {
            if let info = try? info.result?.get() {
                SessionHeader(info: info)
            }
        }
        .autoRefresh(rotating: [
            { await events.fetchLatest(for: query, in: database) },
            { await info.fetchLatest(in: database) },
        ])
        .navigationTitle(en: "Session")
    }

    private var query: Event.Query {
        Event.Query(sessionID: sessionID)
    }
}

#Preview {
    let events = EventProvider()
    events.events = .samples

    let info = SessionInfoProvider(sessionID: UUID(), deviceID: UUID())
    info.result = .success(.sample)

    return NavigationStack {
        SessionInspector(sessionID: UUID(), deviceID: UUID(), events: events, info: info)
    }
}

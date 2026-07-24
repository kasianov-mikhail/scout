//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct SessionInspector: View {
    let sessionID: UUID
    let deviceID: UUID?

    @StateObject private var events: EventProvider
    @StateObject private var info: SessionInfoProvider

    init(sessionID: UUID, deviceID: UUID?, events: EventProvider? = nil, info: SessionInfoProvider? = nil) {
        self.sessionID = sessionID
        self.deviceID = deviceID
        self._events = StateObject(wrappedValue: events ?? EventProvider(filter: EventQuery(sessionID: sessionID)))
        self._info = StateObject(wrappedValue: info ?? SessionInfoProvider(sessionID: sessionID, deviceID: deviceID))
    }

    var body: some View {
        EventList(provider: events) {
            if let info = try? info.result?.get() {
                SessionHeader(info: info)
            }
        }
        .periodRefresh(providers: [events, info])
        .navigationTitle(en: "Session")
        .largeNavigationTitle()
    }
}

#Preview {
    NavigationStack {
        SessionInspector(
            sessionID: UUID(),
            deviceID: UUID(),
            events: .init().holding(.samples),
            info: .init(sessionID: UUID(), deviceID: UUID()).holding(.sample)
        )
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SessionInspector: View {
    @Environment(\.database) private var database
    @StateObject private var events: EventProvider
    @StateObject private var info: SessionInfoProvider

    init(sessionID: UUID, deviceID: UUID?, events: EventProvider? = nil, info: SessionInfoProvider? = nil) {
        self._events = StateObject(wrappedValue: events ?? EventProvider(filter: EventQuery(sessionID: sessionID)))
        self._info = StateObject(wrappedValue: info ?? SessionInfoProvider(sessionID: sessionID, deviceID: deviceID))
    }

    var body: some View {
        EventList(provider: events) {
            switch info.result {
            case .success(let value):
                SessionHeader(info: value)
            case .failure(let error):
                ErrorRow(description: error.localizedDescription) {
                    await info.fetchAgain(in: database)
                }
            case nil:
                EmptyView()
            }
        }
        .refreshes([events, info])
        .navigationTitle(en: "Session")
        .largeNavigationTitle()
    }
}

#Preview {
    NavigationStack {
        SessionInspector(
            sessionID: UUID(),
            deviceID: UUID(),
            events: .init(.samples),
            info: .init(.success(.sample), sessionID: UUID(), deviceID: UUID())
        )
    }
}

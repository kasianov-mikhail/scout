//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct SessionInspector: View {
    @Environment(\.database) private var database
    @StateObject var provider: SessionTimelineProvider

    init(sessionID: UUID, deviceID: UUID?, provider: SessionTimelineProvider? = nil) {
        self._provider = StateObject(wrappedValue: provider ?? SessionTimelineProvider(sessionID: sessionID, deviceID: deviceID))
    }

    var body: some View {
        Group {
            switch provider.result {
            case .success(let timeline):
                SessionTimelineView(timeline: timeline)
            case .failure(let error):
                ErrorView(description: Text(verbatim: error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            case nil:
                SessionTimelinePlaceholder()
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .navigationTitle(en: "Session")
        .inlineNavigationTitle()
        .fetchTask([provider])
    }
}

#Preview {
    NavigationStack {
        SessionInspector(
            sessionID: UUID(),
            deviceID: UUID(),
            provider: .init(.success(.sample), sessionID: UUID(), deviceID: UUID())
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        SessionInspector(sessionID: UUID(), deviceID: UUID())
    }
}

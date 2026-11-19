//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

#Preview {
    let params = ParamProvider.Item.samplePurchase
    let event = Event(
        name: "IPRecordFailed",
        level: .warning,
        date: Date(),
        paramCount: params.count,
        uuid: UUID(),
        id: UUID().uuidString,
        installID: UUID(),
        sessionID: UUID(),
        deviceID: UUID()
    )

    let param = ParamProvider(.success(params.sorted()), recordID: event.id)
    let stat = StatProvider(.success(.samples), subject: .event(event.name))
    let context = EventContextProvider(.success(.sample), sessionID: UUID(), deviceID: UUID())

    return NavigationStack {
        EventView(event: event, param: param, stat: stat, context: context)
    }
    .environmentObject(Tint())
}

#Preview("Loading") {
    let event = Event(
        name: "IPRecordFailed",
        level: .warning,
        date: Date(),
        paramCount: 3,
        uuid: UUID(),
        id: UUID().uuidString,
        installID: UUID(),
        sessionID: UUID(),
        deviceID: UUID()
    )

    let param = ParamProvider(recordID: event.id)
    let stat = StatProvider(subject: .event(event.name))
    let context = EventContextProvider(sessionID: UUID(), deviceID: UUID())

    return NavigationStack {
        EventView(event: event, param: param, stat: stat, context: context)
    }
    .environmentObject(Tint())
}

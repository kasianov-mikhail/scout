//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct EventStatList: View {
    let range: Range<Date>

    @StateObject var provider: EventProvider

    init(eventName: String, range: Range<Date>, provider: EventProvider? = nil) {
        self.range = range
        self._provider = StateObject(
            wrappedValue: provider ?? EventProvider(filter: EventQuery(name: eventName, dates: range))
        )
    }

    var body: some View {
        VStack {
            EventList(provider: provider)
                .periodRefresh(provider: provider)
                .navigationTitle(en: range.label(using: rangeDateFormatter))
                .font(.caption)
        }
    }
}

#Preview {
    let provider = EventProvider()
    provider.records = .samples

    return NavigationStack {
        EventStatList(eventName: "Event", range: Period.week.initialRange, provider: provider)
    }
}

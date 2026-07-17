//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct EventStatList: View {
    let eventName: String
    let range: Range<Date>

    @StateObject var provider = EventProvider()
    @Environment(\.database) var database

    var body: some View {
        VStack {
            EventList(provider: provider)
                .autoRefresh {
                    await provider.fetchLatest(for: query, in: database)
                }
                .navigationTitle(range.label(using: eventRangeDateFormatter))
                .font(.caption)
        }
    }

    var query: EventQuery {
        EventQuery(name: eventName, dates: range)
    }
}

private let eventRangeDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "d MMM"
    return formatter
}()

#Preview {
    let provider = EventProvider()
    provider.records = .samples

    return NavigationStack {
        EventStatList(eventName: "Event", range: Period.week.initialRange, provider: provider)
    }
}

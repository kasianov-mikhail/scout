//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct EventStatList: View {
    let eventName: String
    let range: Range<Date>

    @StateObject var provider = EventProvider()
    @Environment(\.database) var database

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "d MMM"
        return formatter
    }()

    var body: some View {
        VStack {
            EventList(provider: provider)
                .task {
                    await provider.fetchIfNeeded(for: query, in: database)
                }
                .navigationTitle(range.label(using: formatter))
                .font(.caption)
        }
    }

    var query: Event.Query {
        var query = Event.Query()
        query.dates = range
        query.name = eventName
        return query
    }
}

#Preview {
    NavigationStack {
        EventStatList(eventName: "Event", range: Period.week.initialRange, provider: .fixture())
    }
}

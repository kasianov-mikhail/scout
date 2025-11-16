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

    @StateObject private var provider = EventProvider()
    @Environment(\.database) var database

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "d MMM"
        return formatter
    }()

    var body: some View {
        VStack {
            EventList(provider: provider)
                .task {
                    await fetch()
                }
                .refreshable {
                    await fetch()
                }
                .navigationTitle(range.label(using: formatter))
                .font(.system(size: 12))
        }
    }

    func fetch() async {
        var query = Event.Query()
        query.dates = range
        query.name = eventName
        await provider.fetch(for: query, in: database)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EventStatList(eventName: "Event", range: Period.week.initialRange)
    }
}

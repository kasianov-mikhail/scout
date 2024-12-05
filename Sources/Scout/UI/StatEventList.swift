//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct StatEventList: View {
    let eventName: String
    let range: Range<Date>

    @StateObject private var provider = EventProvider()
    @EnvironmentObject private var database: DatabaseController

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
                .navigationTitle(range.rangeLabel(formatter: formatter))
                .font(.system(size: 12))
        }
    }

    func fetch() async {
        var query = EventQuery()
        query.dates = range
        query.name = eventName
        await provider.fetch(for: query, in: database)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StatEventList(eventName: "Event", range: StatPeriod.week.range)
            .environmentObject(DatabaseController())
    }
}

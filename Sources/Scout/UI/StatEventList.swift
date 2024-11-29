//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct StatEventList: View {
    let eventName: String
    @Binding private var period: StatPeriod

    @StateObject private var provider = EventProvider()
    @EnvironmentObject private var database: DatabaseController

    init(eventName: String, period: Binding<StatPeriod>) {
        self.eventName = eventName
        self._period = period
    }

    var body: some View {
        VStack {
            PeriodPicker(period: $period)

            EventList(provider: provider)
                .task {
                    await fetch()
                }
                .refreshable {
                    await fetch()
                }
                .onChange(of: period) { _ in
                    Task {
                        provider.events = nil
                        await fetch()
                    }
                }
                .navigationTitle("Events")
        }
    }

    func fetch() async {
        var query = EventQuery()
        query.dates = period.range
        query.name = eventName
        await provider.fetch(for: query, in: database)
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var period = StatPeriod.week

    NavigationStack {
        StatEventList(eventName: "Event", period: $period)
            .environmentObject(DatabaseController())
    }
}

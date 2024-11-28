//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct StatEventList: View {
    @StateObject private var provider = EventProvider()
    @EnvironmentObject private var database: DatabaseController

    @Binding private var period: StatPeriod

    init(period: Binding<StatPeriod>) {
        _period = period
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
                .navigationTitle(period.title)
        }
    }

    func fetch() async {
        var query = EventQuery()
        query.dates = period.range
        await provider.fetch(for: query, in: database)
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var period = StatPeriod.week

    NavigationStack {
        StatEventList(period: $period)
            .environmentObject(DatabaseController())
    }
}

//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var tint: Tint
    @EnvironmentObject var database: DatabaseController

    @State private var filter: HistoryFilter
    @StateObject var provider = EventProvider()

    init(filter: HistoryFilter) {
        _filter = State(wrappedValue: filter)
    }

    var body: some View {
        VStack {
            Picker("", selection: $filter.category) {
                ForEach(HistoryFilter.Category.allCases) { category in
                    Text(category.title)
                }
            }
            .padding(.horizontal)
            .pickerStyle(.segmented)

            EventList(provider: provider)
                .frame(maxHeight: .infinity)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    filter.option.toggle()
                } label: {
                    Text(filter.option.title)
                }
            }
        }
        .onAppear {
            tint.value = nil
        }
        .task {
            await fetch()
        }
        .refreshable {
            await fetch()
        }
        .onChange(of: filter.category) { _ in
            Task {
                provider.events = nil
                await fetch()
            }
        }
        .onChange(of: filter.option) { _ in
            Task {
                provider.events = nil
                await fetch()
            }
        }
        .navigationTitle("History")
    }

    func fetch() async {
        await provider.fetch(
            for: filter.query(),
            in: database
        )
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        let filter = HistoryFilter(
            name: "event_name",
            userID: UUID(),
            sessionID: UUID(),
            category: .session
        )
        HistoryView(filter: filter)
    }
    .environmentObject(DatabaseController())
    .environmentObject(Tint())
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct IncidentGroupLoader<Element: RecordDecodable & Incident, Content: View>: View {
    @StateObject private var provider: IncidentOccurrencesProvider<Element>
    @Environment(\.database) var database

    let content: (IncidentOccurrencesProvider<Element>) -> Content

    init(tally: IncidentTally, @ViewBuilder content: @escaping (IncidentOccurrencesProvider<Element>) -> Content) {
        _provider = StateObject(wrappedValue: IncidentOccurrencesProvider(tally: tally))
        self.content = content
    }

    var body: some View {
        Group {
            if let records = provider.records {
                if records.isEmpty {
                    Placeholder(text: "No occurrences")
                } else {
                    content(provider)
                }
            } else if let error = provider.error {
                ErrorView(description: error.localizedDescription) {
                    await provider.fetchIfNeeded(in: database)
                }
            } else {
                RingIndicator().frame(maxHeight: .infinity)
            }
        }
        .task {
            await provider.fetchIfNeeded(in: database)
        }
    }
}

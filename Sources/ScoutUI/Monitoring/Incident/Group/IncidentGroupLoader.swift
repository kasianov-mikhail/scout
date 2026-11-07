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
                        .monospacedNavigationTitle(en: provider.name)
                } else {
                    content(provider)
                        .transition(.opacity)
                }
            } else if let error = provider.error {
                ErrorView(description: error.localizedDescription) {
                    await provider.fetchIfNeeded(in: database)
                }
                .monospacedNavigationTitle(en: provider.name)
            } else {
                IncidentGroupPlaceholder(kind: Element.kind)
                    .monospacedNavigationTitle(en: provider.name)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.records == nil)
        .toolbarBackground(Element.kind.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await provider.fetchIfNeeded(in: database)
        }
    }
}

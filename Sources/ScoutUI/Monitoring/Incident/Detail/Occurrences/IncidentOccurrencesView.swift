//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct IncidentOccurrencesView<Element: RecordDecodable & Incident, Row: View>: View {
    @ObservedObject var occurrences: IncidentOccurrencesProvider<Element>
    @ViewBuilder let row: (Element) -> Row

    @Environment(\.database) private var database

    var body: some View {
        Group {
            if let records = occurrences.records {
                if records.isEmpty {
                    Placeholder(text: "No occurrences")
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                                row(record)
                                    .overlay(alignment: .bottom) {
                                        if index < records.count - 1 || occurrences.cursor != nil {
                                            Separator()
                                        }
                                    }
                            }

                            if let cursor = occurrences.cursor {
                                PaginationFooter {
                                    await occurrences.fetchMore(cursor: cursor, in: database)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .scrollIndicators(.hidden)
                }
            } else if let error = occurrences.error {
                ErrorView(description: error.localizedDescription) {
                    await occurrences.fetchIfNeeded(in: database)
                }
            } else {
                RingIndicator()
                    .frame(maxHeight: .infinity)
            }
        }
        .message($occurrences.message)
        .monospacedNavigationTitle(en: occurrences.name)
        .toolbarBackground(Element.kind.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

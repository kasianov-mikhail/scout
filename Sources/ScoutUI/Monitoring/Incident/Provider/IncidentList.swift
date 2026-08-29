//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct IncidentList<Element: RecordDecodable & Incident, Row: View>: View {
    @Environment(\.database) var database
    @ObservedObject var provider: IncidentProvider<Element>

    let title: String
    let placeholder: Placeholder

    @ViewBuilder let row: (IncidentGroup<Element>) -> Row

    var body: some View {
        Group {
            if let groups = provider.groups {
                if groups.isEmpty {
                    placeholder
                } else {
                    InsetList {
                        ForEach(groups, content: row)

                        if let cursor = provider.cursor {
                            PaginationFooter {
                                await provider.fetchMore(cursor: cursor, in: database)
                            }
                        }
                    }
                    .animation(nil, value: groups)
                }
            } else if let error = provider.error {
                ErrorView(description: error.localizedDescription) {
                    await provider.fetchAgain(in: database)
                }
            } else {
                RingIndicator().frame(maxHeight: .infinity)
            }
        }
        .navigationTitle(en: title)
        .message($provider.message)
        .refreshes([provider])
    }
}

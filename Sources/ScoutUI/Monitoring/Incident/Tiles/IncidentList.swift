//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct IncidentList<Element: RecordDecodable & Incident, Destination: View>: View {
    @ObservedObject var provider: IncidentTilesProvider<Element>
    let placeholder: Placeholder

    @ViewBuilder let destination: (IncidentTally) -> Destination

    @Environment(\.database) private var database

    var body: some View {
        content
            .animation(.easeOut(duration: 0.2), value: provider.result == nil)
            .navigationTitle(en: Element.kind.title)
            .inlineNavigationTitle()
            .message($provider.message)
            .task(id: provider.range) {
                await provider.fetchAgain(in: database)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch provider.result {
        case nil:
            IncidentListPlaceholder(range: $provider.range)
                .transition(.opacity)
        case .success(let tiles):
            if tiles.isEmpty {
                placeholder
            } else {
                list(tiles)
                    .transition(.opacity)
            }
        case .failure(let error):
            ErrorView(description: Text(error.localizedDescription)) {
                await provider.fetchAgain(in: database)
            }
        }
    }

    private func list(_ tiles: [IncidentTile<Element>]) -> some View {
        InsetList {
            IncidentRangeStrip(selection: $provider.range)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)

            summary(tiles)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)

            IncidentGrid(count: tiles.count) { index in
                let tile = tiles[index]

                NavigationLink {
                    destination(tile.tally)
                } label: {
                    IncidentTileView(
                        tile: tile,
                        side: index.isMultiple(of: 2) ? .leading : .trailing
                    )
                }
                .buttonStyle(.plain)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
        }
        .scrollContentBackground(.hidden)
    }

    private func summary(_ tiles: [IncidentTile<Element>]) -> some View {
        let count = tiles.map(\.count).reduce(0, +)
        let groups = tiles.count

        return
            (Text(verbatim: "\(count) \(Element.kind.noun(for: count)) in \(groups) \(groups == 1 ? "group" : "groups") · ")
            + Text(verbatim: Element.kind.captionName).foregroundColor(Element.kind.labelColor)
            + Text(verbatim: " is today"))
            .font(.system(size: 15))
            .foregroundStyle(Color(.systemGray))
    }
}

extension IncidentKind {
    func noun(for count: Int) -> String {
        count == 1 ? noun : pluralNoun
    }
}

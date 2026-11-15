//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

let telemetryColumns = [
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
]

struct HomeTelemetrySection: View {
    let items: [TelemetryItem]?
    let onSelect: (TelemetryItem.Kind) -> Void

    var body: some View {
        if let items {
            content(items: items)
        } else {
            HomeTelemetrySectionPlaceholder()
        }
    }

    private func content(items: [TelemetryItem]) -> some View {
        Section(bottomGap: .space2) {
            SectionHeader(titles: ["TELEMETRY", "INCIDENTS"])
        } content: {
            LazyVGrid(columns: telemetryColumns, spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]

                    TelemetryRow(
                        item: item,
                        side: index.isMultiple(of: 2) ? .leading : .trailing,
                        showsDivider: index / 2 < (items.count - 1) / 2,
                        showsValues: items.hasValues
                    ) {
                        onSelect(item.kind)
                    }
                }
            }
            .overlay {
                Rectangle()
                    .fill(Color.separator)
                    .frame(width: 0.5)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeTelemetrySection(items: TelemetryItem.sample) { _ in }
                HomeTelemetrySection(items: nil) { _ in }
            }
        }
        .scrollIndicators(.hidden)
    }
}

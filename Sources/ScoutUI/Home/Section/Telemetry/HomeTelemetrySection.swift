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
        VStack(alignment: .leading, spacing: 0) {
            header

            LazyVGrid(columns: telemetryColumns, spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]

                    TelemetryRow(
                        item: item,
                        side: index.isMultiple(of: 2) ? .leading : .trailing,
                        showsDivider: index / 2 < (items.count - 1) / 2
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
        .padding(.bottom, 6)
    }

    private var header: some View {
        HStack(spacing: 0) {
            Text(verbatim: "TELEMETRY")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(verbatim: "INCIDENTS")
                .padding(.leading, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.callout.weight(.bold))
        .padding(.top, 12)
        .frame(height: 70)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}

#Preview {
    NavigationStack {
        InsetList {
            HomeTelemetrySection(items: TelemetryItem.sample) { _ in }
            HomeTelemetrySection(items: nil) { _ in }
        }
    }
}

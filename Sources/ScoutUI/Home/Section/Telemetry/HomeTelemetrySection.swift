//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeTelemetrySection: View {
    let items: [TelemetryItem]
    let onSelect: (TelemetryItem.Kind) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            LazyVGrid(columns: columns, spacing: 0) {
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
        }
        .padding(.bottom, 6)
        .listRowSeparator(.hidden)
    }

    private var header: some View {
        HStack(spacing: 0) {
            Text(verbatim: "TELEMETRY")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(verbatim: "INCIDENTS")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.callout.weight(.bold))
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
        }
    }
}

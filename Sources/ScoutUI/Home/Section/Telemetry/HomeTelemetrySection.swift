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
    let items: [TelemetryItem]
    @Binding private var path: NavigationPath

    init(items: [TelemetryItem], path: Binding<NavigationPath>) {
        self.items = items
        self._path = path
    }

    var body: some View {
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
                        path.append(item.kind)
                    }
                }
            }
            .overlay {
                Separator(axis: .vertical)
            }
        }
        .navigationDestination(for: TelemetryItem.Kind.self) { kind in
            switch kind {
            case .events:
                LogDestination(category: .events)
            case .crashes:
                LogDestination(category: .crashes)
            case .metrics:
                LogDestination(category: .metrics)
            case .hangs:
                LogDestination(category: .hangs)
            case .network:
                LogDestination(category: .network)
            case .resources:
                ResourceListView()
            }
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @State var path = NavigationPath()

    NavigationStack(path: $path) {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeTelemetrySection(items: TelemetryItem.sample, path: $path)
                HomeTelemetrySection.Placeholder()
            }
        }
        .scrollIndicators(.hidden)
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct IncidentRow<Element: Incident, Destination: View>: View {
    let group: IncidentGroup<Element>
    var accent: (systemImage: String, color: Color)? = nil
    @ViewBuilder let destination: (IncidentGroup<Element>) -> Destination

    var body: some View {
        Row {
            if let accent {
                Image(systemName: accent.systemImage)
                    .frame(width: 20)
                    .foregroundStyle(accent.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(group.name)
                    .font(.callout)
                    .lineLimit(1)
                if let symbol = group.symbol {
                    Text(verbatim: symbol)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
            }
            .monospaced()

            if group.count > 1 || group.isPartial {
                if let accent {
                    CountBadge(count: group.count, prefix: "×", suffix: group.countSuffix, color: accent.color)
                } else {
                    CountBadge(count: group.count, prefix: "×", suffix: group.countSuffix)
                }
            }

            Spacer()

            if let date = group.lastDate {
                Text(verbatim: date.relativeString)
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
            }
        } destination: {
            destination(group)
        }
    }
}

#Preview {
    NavigationStack {
        InsetList {
            IncidentRow(group: IncidentGroup(records: [Crash].samples)) { group in
                CrashDetailView(crash: group.representative)
            }
            IncidentRow(
                group: IncidentGroup(
                    id: "MyApp|CartViewModel.applyDiscount(_:)",
                    records: [Crash].samples,
                    symbol: "CartViewModel.applyDiscount(_:)"
                )
            ) { group in
                CrashDetailView(crash: group.representative)
            }
        }
        .navigationTitle(en: "Crashes")
    }
    .environmentObject(Tint())
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// The selected period's title that opens a menu of all periods.
///
/// Set like a section header title, but in secondary color, compact
/// enough to sit at the trailing edge of a section header.
///
struct CompactPeriodPicker: View {
    @Binding var selection: Period

    var body: some View {
        Menu {
            Picker(selection: $selection) {
                ForEach(Period.allCases) { period in
                    Text(period.title)
                }
            } label: {
                Text(verbatim: "Period")
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 12, weight: .medium))
                Text(selection.shortTitle.uppercased())
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct Preview: View {
        @State private var selection = Period.today

        var body: some View {
            List {
                HStack {
                    Text(verbatim: "Period")
                    Spacer()
                    CompactPeriodPicker(selection: $selection)
                }
            }
            .listStyle(.plain)
        }
    }
    return Preview()
}

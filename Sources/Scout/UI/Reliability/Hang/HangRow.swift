//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HangRow: View {
    let group: ReliabilityGroup<Hang>

    var body: some View {
        Row {
            Image(systemName: group.severity.systemImage)
                .frame(width: 20)
                .foregroundStyle(group.severity.color)

            Text(group.name)
                .font(.body)
                .lineLimit(1)
                .monospaced()

            if group.count > 1 {
                CountBadge(count: group.count, prefix: "×", color: group.severity.color)
            }

            Spacer()

            if let date = group.lastDate {
                Text(verbatim: date.relativeString)
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
            }
        } destination: {
            HangGroupDetailView(group: group)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            ForEach(ReliabilityGroup.groups(from: Hang.samples)) { group in
                HangRow(group: group)
            }
        }
        .listStyle(.plain)
        .navigationTitle(en: "Hangs")
    }
    .environmentObject(Tint())
}

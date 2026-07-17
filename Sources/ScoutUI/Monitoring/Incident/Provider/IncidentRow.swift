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

            Text(group.name)
                .font(.body)
                .lineLimit(1)
                .monospaced()

            if group.count > 1 {
                if let accent {
                    CountBadge(count: group.count, prefix: "×", color: accent.color)
                } else {
                    CountBadge(count: group.count, prefix: "×")
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

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeLogRow<Destination: View>: View {
    let title: String
    let image: String
    let color: Color
    let count: Int?

    @ViewBuilder let destination: () -> Destination

    var body: some View {
        Row {
            Image(systemName: image)
                .foregroundColor(color)
                .frame(width: 24)
            Text(verbatim: title)
            Spacer()
            RedactedText(count: count)
                .foregroundStyle(color)
                .frame(minWidth: RowSummary.countWidth, alignment: .trailing)
        } destination: {
            destination()
        }
    }
}

#Preview {
    NavigationStack {
        List {
            HomeLogRow(title: "Events", image: "list.bullet", color: .blue, count: 42) {
                Text(verbatim: "Detail")
            }
            HomeLogRow(title: "Metrics", image: "chart.bar", color: .blue, count: nil) {
                Text(verbatim: "Detail")
            }
        }
        .listStyle(.plain)
    }
}

//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct StatRow<Destination: View>: View {
    let color: Color
    let period: Period

    @ObservedObject var stat: StatProvider
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        Row {
            Group {
                Text(period.title)
                Spacer()

                let count = try? stat.result?.get()
                    .flatMap(\.points)
                    .bucket(on: period)
                    .total

                RedactedText(count: count)
            }
            .foregroundColor(color)
        } destination: {
            destination()
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        List {
            StatRow(
                color: .blue,
                period: .today,
                stat: StatProvider(eventName: "event_name", periods: Period.allCases)
            ) {
                Text("Detail")
            }
        }
    }
}

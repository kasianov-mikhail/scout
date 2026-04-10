//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct StatRow: View {
    let title: String
    let color: Color
    let showList: Bool
    let period: Period

    @ObservedObject var stat: StatProvider

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
            StatView(
                title: title,
                color: color,
                showList: showList,
                stat: stat,
                period: period
            )
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        List {
            StatRow(
                title: "Events",
                color: .blue,
                showList: true,
                period: .today,
                stat: StatProvider(eventName: "event_name", periods: Period.allCases)
            )
        }
    }
}

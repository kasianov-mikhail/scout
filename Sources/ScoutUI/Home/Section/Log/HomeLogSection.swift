//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeLogSection: View {
    @Environment(\.database) var database

    let period: Period

    @ObservedObject var log: HomeLogProvider

    @Binding var path: [HomeDestination]

    var body: some View {
        Header(title: "Log") {
            AllButton { path.append(.log) }
        }
        .task(id: period) {
            guard log.period != period else {
                return
            }

            log.period = period
            await log.fetchIfNeeded(in: database)
        }

        ForEach(LogCategory.allCases, id: \.self) { category in
            Row {
                Image(systemName: category.systemImage)
                    .foregroundStyle(category.color)
                    .frame(width: 24)
                Text(verbatim: category.title)
                Spacer()
                RedactedText(count: log.report?[category]?.count)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: RowSummary.countWidth, alignment: .trailing)
            } destination: {
                LogDestination(category: category)
            }
        }
    }
}

extension HomeLogSection {
    init(period: Period) {
        self.init(
            period: period,
            log: .init(acrossAllPeriods: .sample(for: period)),
            path: .constant([])
        )
    }
}

#Preview {
    NavigationStack {
        InsetList {
            HomeLogSection(period: .today)
        }
    }
}

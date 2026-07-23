//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeLogSection: View {
    @Environment(\.database) var database

    let period: Period

    @ObservedObject var log: HomeLogProvider
    @ObservedObject var devices: DevicesProvider

    @Binding var path: [HomeDestination]

    var body: some View {
        Header(title: "Log") {
            AllButton { path.append(.log) }
        }
        .task(id: period) {
            log.period = period
            log.visits = visits
            await log.fetchIfNeeded(in: database)
        }
        .onChange(of: visits) { log.visits = $0 }

        ForEach(Array(LogCategory.allCases.enumerated()), id: \.element) { index, category in
            Row {
                Image(systemName: category.systemImage)
                    .foregroundColor(category.color)
                    .frame(width: 24)
                Text(verbatim: category.title)
                Spacer()
                RedactedText(count: log.report?.trend(for: category).count)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: RowSummary.countWidth, alignment: .trailing)
            } destination: {
                LogDestination(category: category)
            }
        }
    }

    private var visits: [DeviceVisit] {
        (try? devices.result?.get().visits) ?? []
    }
}

#Preview {
    NavigationStack {
        InsetList {
            HomeLogSection(period: .today)
        }
    }
}

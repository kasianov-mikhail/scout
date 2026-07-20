//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeAlertSection: View {
    @ObservedObject var alerts: AlertProvider

    @Binding var path: [HomeDestination]

    var body: some View {
        Header(title: "Alerts") {
            HStack(spacing: 8) {
                if let statuses = try? alerts.result?.get() {
                    FiringBadge(count: statuses.firingCount)
                }

                AllButton { path.append(.alerts) }
            }
        }

        switch alerts.result {
        case .success(let statuses) where statuses.count > 0:
            ForEach(statuses.prefix(2), id: \.rule) { status in
                AlertRow(status: status)
            }

        case .success:
            Text(verbatim: "No alert rules")
                .placeholderTextStyle()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .listRowSeparator(.hidden)

        default:
            ForEach(0..<2, id: \.self) { _ in
                AlertRowPlaceholder()
            }
        }
    }
}

#Preview {
    let alerts = AlertProvider()
    alerts.result = .success([.firingSample, .armedSample])

    let empty = AlertProvider()
    empty.result = .success([])

    return NavigationStack {
        List {
            HomeAlertSection(alerts: alerts, path: .constant([]))
            HomeAlertSection(alerts: empty, path: .constant([]))
        }
        .listStyle(.plain)
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct TimerDistributionSection: View {
    let extent: ChartExtent<Period>

    @StateObject var provider: TimerDistributionProvider
    @Environment(\.database) var database

    init(name: String, extent: ChartExtent<Period>, provider: TimerDistributionProvider? = nil) {
        self.extent = extent
        self._provider = StateObject(wrappedValue: provider ?? TimerDistributionProvider(name: name))
    }

    var body: some View {
        Group {
            switch provider.result {
            case .success(let distribution):
                if let percentiles = distribution.summary(in: extent.domain) {
                    TimerDistributionView(
                        percentiles: percentiles,
                        trend: distribution.trend(in: extent.domain, component: extent.period.pointComponent),
                        unit: extent.period.pointComponent
                    )
                }
            default:
                EmptyView()
            }
        }
        .listRowSeparator(.hidden)
        .autoRefresh {
            await provider.fetchLatest(in: database)
        }
    }
}

#Preview("TimerDistributionSection") {
    let provider = TimerDistributionProvider(name: "http_request")
    provider.result = .success(.sample)

    return NavigationStack {
        List {
            TimerDistributionSection(
                name: "http_request",
                extent: ChartExtent(period: .today),
                provider: provider
            )
        }
        .listStyle(.plain)
        .monospacedNavigationTitle(en: "http_request")
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct MetricDistributionSection<H: QuantileHistogram>: View {
    let extent: ChartExtent<Period>
    let formatter: KeyPath<Double, String>

    @Environment(\.database) private var database
    @StateObject var provider: MetricDistributionProvider<H>

    init(name: String, categories: [String], extent: ChartExtent<Period>, formatter: KeyPath<Double, String>, provider: MetricDistributionProvider<H>? = nil) {
        self.extent = extent
        self.formatter = formatter
        self._provider = StateObject(
            wrappedValue: provider ?? MetricDistributionProvider(name: name, categories: categories))
    }

    var body: some View {
        VStack(alignment: .leading) {
            switch provider.result {
            case .success(let distribution):
                if let percentiles = distribution.summary(in: extent.domain) {
                    MetricDistributionView(
                        percentiles: percentiles,
                        trend: distribution.trend(in: extent.domain, component: extent.period.pointComponent),
                        unit: extent.period.pointComponent,
                        formatter: formatter
                    )
                }
            case .failure(let error):
                ErrorRow(description: error.localizedDescription) {
                    await provider.fetchAgain(in: database)
                }
            case nil:
                EmptyView()
            }
        }
        .listRowSeparator(.hidden)
        .fetchTask([provider])
    }
}

#Preview("Timer") {
    let provider = MetricDistributionProvider<LatencyHistogram>(
        .success(.sample),
        name: "http_request",
        categories: []
    )

    return NavigationStack {
        InsetList {
            MetricDistributionSection(
                name: "http_request",
                categories: [],
                extent: ChartExtent(period: .today),
                formatter: \TimeInterval.duration,
                provider: provider
            )
        }
        .monospacedNavigationTitle(en: "http_request")
    }
}

#Preview("Recorder") {
    let provider = MetricDistributionProvider<RecorderHistogram>(
        .success(.sample),
        name: "payload_size",
        categories: []
    )

    return NavigationStack {
        InsetList {
            MetricDistributionSection(
                name: "payload_size",
                categories: [],
                extent: ChartExtent(period: .today),
                formatter: \Double.decimal,
                provider: provider
            )
        }
        .monospacedNavigationTitle(en: "payload_size")
    }
}

#Preview("Failure") {
    let provider = MetricDistributionProvider<LatencyHistogram>(
        .failure(URLError(.timedOut)),
        name: "http_request",
        categories: []
    )

    return NavigationStack {
        InsetList {
            MetricDistributionSection(
                name: "http_request",
                categories: [],
                extent: ChartExtent(period: .today),
                formatter: \TimeInterval.duration,
                provider: provider
            )
        }
        .monospacedNavigationTitle(en: "http_request")
    }
}

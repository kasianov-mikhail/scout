//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct MetricDistributionDetailView<H: QuantileHistogram>: View {
    let name: String
    let telemetry: Telemetry.Export

    @Binding var range: MetricRange

    @State private var quantile: MetricQuantile
    @StateObject var provider: MetricDistributionProvider<H>
    @Environment(\.database) private var database

    init(name: String, telemetry: Telemetry.Export, categories: [String], range: Binding<MetricRange>, result: ProviderResult<MetricDistribution<H>>? = nil) {
        self.name = name
        self.telemetry = telemetry
        self._range = range
        self._quantile = State(wrappedValue: telemetry == .timer ? .p90 : .p50)
        self._provider = StateObject(wrappedValue: MetricDistributionProvider(result, name: name, categories: categories))
    }

    var body: some View {
        Group {
            switch provider.result {
            case nil:
                MetricDetailPlaceholder(kind: .distribution(telemetry), range: $range)
                    .transition(.opacity)
            case .success(let distribution):
                content(distribution)
                    .transition(.opacity)
            case .failure(let error):
                ErrorView(description: Text(verbatim: error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .fetchTask([provider])
    }

    @ViewBuilder
    private func content(_ distribution: MetricDistribution<H>) -> some View {
        let now = Date()
        let format = MetricValueFormat(telemetry: telemetry)
        let summary = distribution.summary(range: range, now: now)
        let previous = distribution.previousSummary(range: range, now: now)
        let samples = distribution.histogram(range: range, now: now).total
        let buckets = distribution.buckets(range: range, quantile: quantile, now: now)
        let histogram = distribution.histogram(range: range, now: now)

        if histogram.total == 0 {
            VStack(spacing: 0) {
                MetricRangeStrip(selection: $range)
                    .padding(.top, 8)
                    .padding(.leading, 16)

                Placeholder(
                    text: "No data",
                    systemImage: "chart.bar",
                    description: "No values have been recorded for this metric in this period"
                )
            }
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    MetricRangeStrip(selection: $range)
                        .padding(.top, 8)
                        .padding(.trailing, -16)

                    MetricQuantileSelector(
                        summary: summary,
                        previous: previous,
                        telemetry: telemetry,
                        format: format,
                        selection: $quantile
                    )
                    .padding(.top, 4)

                    Text(verbatim: "\(samples.formatted(.number.locale(Locale(identifier: "en_US")))) samples · change \(range.headlineComparison)")
                        .font(.book(size: 13))
                        .foregroundStyle(Color(.systemGray))
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MetricChart(buckets: buckets, style: .line(filled: true), format: format)
                        .padding(.top, 16)

                    MetricAxisLabels(labels: range.axisLabels(now: now))

                    MetricLegend(title: range.previousTitle, note: nil)

                    MetricSectionHeader(title: "DISTRIBUTION", trailing: distributionCaption)

                    MetricHistogramChart(
                        counts: histogram.counts,
                        bounds: H.bounds,
                        percentiles: summary,
                        format: histogramFormat
                    )
                    .padding(.top, 8)

                    MetricSectionHeader(title: range.sectionTitle, trailing: "\(quantile.title.lowercased()) \(range.comparisonTitle)")

                    ForEach(buckets.rows) { row in
                        MetricBucketRow(
                            row: row,
                            label: range.rowLabel(date: row.date),
                            format: format,
                            tone: .neutral
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ChartExportButton(title: name, rangeLabel: range.title) {
                        MetricChart(buckets: buckets, style: .line(filled: true), format: format)
                    }
                }
            }
        }
    }

    private var distributionCaption: String {
        range.caption(unit: telemetry == .timer ? "ms" : nil)
    }

    private var histogramFormat: MetricHistogramFormat {
        telemetry == .timer ? .timer : .recorder
    }
}

#Preview("Timer") {
    NavigationStack {
        MetricDistributionDetailView<LatencyHistogram>(
            name: "http.request.duration",
            telemetry: .timer,
            categories: LatencyBuckets.categories,
            range: .constant(.today),
            result: .success(.sample)
        )
        .monospacedNavigationTitle(en: "http.request.duration")
    }
}

#Preview("Recorder") {
    NavigationStack {
        MetricDistributionDetailView<RecorderHistogram>(
            name: "image.upload_kb",
            telemetry: .recorder,
            categories: RecorderBuckets.categories,
            range: .constant(.today),
            result: .success(.sample)
        )
        .monospacedNavigationTitle(en: "image.upload_kb")
    }
}

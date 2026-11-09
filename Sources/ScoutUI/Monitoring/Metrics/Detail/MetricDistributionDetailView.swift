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
            InsetList {
                MetricRangeStrip(selection: $range)
                    .padding(.top, 8)
                    .padding(.trailing, -16)
                    .frame(minHeight: 44)

                MetricQuantileSelector(
                    summary: summary,
                    previous: previous,
                    telemetry: telemetry,
                    format: format,
                    selection: $quantile
                )
                .padding(.top, 4)
                .frame(minHeight: 44)

                Text(verbatim: "\(samples.formatted(.number.locale(Locale(identifier: "en_US")))) samples · change \(range.headlineComparison)")
                    .font(.weight450(size: 13))
                    .foregroundStyle(Color(.systemGray))
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 44)

                MetricChart(buckets: buckets, style: .line(filled: true), format: format)
                    .padding(.top, 16)
                    .frame(minHeight: 44)

                MetricAxisLabels(labels: range.axisLabels(now: now))
                    .frame(minHeight: 44)

                MetricLegend(title: range.previousTitle, note: nil)
                    .frame(minHeight: 44)

                MetricSectionHeader(title: "DISTRIBUTION", trailing: distributionCaption)
                    .frame(minHeight: 44)

                MetricHistogramChart(
                    counts: histogram.counts,
                    bounds: H.bounds,
                    percentiles: summary,
                    format: histogramFormat
                )
                .padding(.top, 8)
                .frame(minHeight: 44)

                MetricSectionHeader(title: range.sectionTitle, trailing: "\(quantile.title.lowercased()) \(range.comparisonTitle)")
                    .frame(minHeight: 44)

                ForEach(buckets.rows) { row in
                    MetricBucketRow(
                        row: row,
                        label: range.rowLabel(date: row.date),
                        format: format,
                        tone: .neutral
                    )
                    .frame(minHeight: 44)
                }
            }
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

private struct MetricQuantileSelector: View {
    let summary: Percentiles?
    let previous: Percentiles?
    let telemetry: Telemetry.Export
    let format: MetricValueFormat

    @Binding var selection: MetricQuantile

    var body: some View {
        HStack(spacing: 12) {
            ForEach(MetricQuantile.allCases) { quantile in
                Button {
                    selection = quantile
                } label: {
                    cell(quantile)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(quantile == selection ? .isSelected : [])
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }

    private func cell(_ quantile: MetricQuantile) -> some View {
        let isSelected = quantile == selection
        let current = summary?.value(quantile)
        let delta = delta(current: current, previous: previous?.value(quantile))

        return VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: quantile.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color.primary : Color(.systemGray))

            Text(verbatim: current.map { format.label($0) } ?? "—")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(isSelected ? Color.primary : Color.inactiveValue)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(verbatim: delta?.formatted ?? "—")
                .font(.weight450(size: 13))
                .foregroundStyle(tone(delta, quantile).color)
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            if isSelected {
                Rectangle()
                    .fill(Color.blue)
                    .frame(height: 2)
            }
        }
        .contentShape(.rect)
    }

    private func delta(current: Double?, previous: Double?) -> Delta? {
        guard let current, let previous else {
            return nil
        }
        return Delta(current: current, previous: previous)
    }

    private func tone(_ delta: Delta?, _ quantile: MetricQuantile) -> MetricTone {
        guard telemetry == .timer, quantile == .p99, let delta, delta.value > 0.1 else {
            return .neutral
        }
        return .warning
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

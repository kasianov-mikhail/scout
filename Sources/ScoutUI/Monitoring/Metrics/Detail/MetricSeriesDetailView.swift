//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct MetricSeriesDetailView<T: ChartNumeric>: View {
    let name: String
    let telemetry: Telemetry.Export

    @Binding var range: MetricRange

    @StateObject var series: MetricsProvider<T>
    @StateObject var resets: ResetMarkerProvider
    @Environment(\.database) private var database

    init(name: String, telemetry: Telemetry.Export, range: Binding<MetricRange>, result: ProviderResult<[MetricSeries]>? = nil, resetDates: ProviderResult<[Date]>? = nil) {
        self.name = name
        self.telemetry = telemetry
        self._range = range
        self._series = StateObject(wrappedValue: MetricsProvider(result, name: name, telemetry: telemetry))
        self._resets = StateObject(wrappedValue: ResetMarkerProvider(resetDates, name: name, isEnabled: telemetry.hasResets))
    }

    var body: some View {
        Group {
            if let error = series.error {
                ErrorView(description: Text(verbatim: error.localizedDescription)) {
                    await series.fetchAgain(in: database)
                }
            } else if isEmpty {
                VStack(spacing: 0) {
                    MetricRangeStrip(selection: $range)

                    Placeholder(
                        text: "No data",
                        systemImage: "chart.bar",
                        description: "No values have been recorded for this metric in this period"
                    )
                }
            } else {
                ScrollView {
                    if case .success(let data) = series.result {
                        content(data)
                            .transition(.opacity)
                    } else {
                        MetricDetailPlaceholder(kind: .series(telemetry), range: $range)
                            .transition(.opacity)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .animation(.easeOut(duration: 0.2), value: series.isLoading)
        .loadingInk(isLoading: series.isLoading)
        .fetchTask([series, resets])
    }

    private func content(_ data: [MetricSeries]) -> some View {
        let now = Date()
        let seriesTimeline = timeline(from: data)
        let format = MetricValueFormat(telemetry: telemetry)
        let buckets = seriesTimeline.buckets(range: range, now: now, fold: telemetry == .meter ? .peak : .total)
        let resetDates = resets.dates(in: range.range(now: now))

        return LazyVStack(alignment: .leading, spacing: 0) {
            MetricRangeStrip(selection: $range)

            MetricSummaryView(summary: summary(timeline: seriesTimeline, now: now, format: format))
                .padding(.horizontal, .gutter)

            MetricChart(buckets: buckets, style: chartStyle, format: format, resets: resetDates)
                .padding(.top, .space16)
                .padding(.horizontal, .gutter)

            MetricAxisLabels(labels: range.axisLabels(now: now))
                .padding(.horizontal, .gutter)

            MetricLegend(title: range.previousTitle, note: legendNote(resetDates: resetDates))
                .padding(.horizontal, .gutter)

            Section(title: range.sectionTitle, note: telemetry == .meter ? "peak \(range.comparisonTitle)" : range.comparisonTitle) {
                ForEach(buckets.rows) { row in
                    MetricBucketRow(
                        row: row,
                        label: range.rowLabel(date: row.date),
                        format: format,
                        tone: tone(row)
                    )
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ChartExportButton(title: name, rangeLabel: range.title) {
                    MetricChart(buckets: buckets, style: chartStyle, format: format, resets: resetDates)
                }
            }
        }
    }
}

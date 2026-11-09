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
            switch series.result {
            case nil:
                MetricDetailPlaceholder(kind: .series(telemetry), range: $range)
                    .transition(.opacity)
            case .success(let data):
                content(data)
                    .transition(.opacity)
            case .failure(let error):
                ErrorView(description: Text(verbatim: error.localizedDescription)) {
                    await series.fetchAgain(in: database)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: series.isLoading)
        .fetchTask([series, resets])
    }

    @ViewBuilder
    private func content(_ data: [MetricSeries]) -> some View {
        let now = Date()
        let seriesTimeline = timeline(from: data)
        let format = MetricValueFormat(telemetry: telemetry)
        let buckets = seriesTimeline.buckets(range: range, now: now, fold: telemetry == .meter ? .peak : .total)
        let resetDates = resets.dates(in: range.range(now: now))

        if !seriesTimeline.containsData(range: range, now: now) {
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

                MetricSummaryView(summary: summary(timeline: seriesTimeline, now: now, format: format))
                    .frame(minHeight: 44)

                MetricChart(buckets: buckets, style: chartStyle, format: format, resets: resetDates)
                    .padding(.top, 16)
                    .frame(minHeight: 44)

                MetricAxisLabels(labels: range.axisLabels(now: now))
                    .frame(minHeight: 44)

                MetricLegend(title: range.previousTitle, note: legendNote(resetDates: resetDates))
                    .frame(minHeight: 44)

                MetricSectionHeader(title: range.sectionTitle, trailing: telemetry == .meter ? "peak \(range.comparisonTitle)" : range.comparisonTitle)
                    .frame(minHeight: 44)

                ForEach(buckets.rows) { row in
                    MetricBucketRow(
                        row: row,
                        label: range.rowLabel(date: row.date),
                        format: format,
                        tone: tone(row)
                    )
                    .frame(minHeight: 44)
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

    private var chartStyle: MetricChart.Style {
        telemetry == .meter ? .line(filled: false) : .bars
    }

    private func summary(timeline: MetricTimeline, now: Date, format: MetricValueFormat) -> MetricSummary {
        telemetry == .meter
            ? timeline.gaugeSummary(range: range, now: now, format: format)
            : timeline.summary(range: range, now: now, format: format)
    }

    private func legendNote(resetDates: [Date]) -> String? {
        switch telemetry {
        case .meter:
            range.peakNote
        case .counter, .floatingCounter:
            resetDates.isEmpty ? nil : "reset = the app restarted the counter"
        case .timer, .recorder:
            nil
        }
    }

    private func tone(_ row: MetricRow) -> MetricTone {
        guard telemetry == .counter || telemetry == .floatingCounter else {
            return .neutral
        }
        guard let delta = row.delta, delta.value > 0 else {
            return .neutral
        }
        return .positive
    }

    private func timeline(from data: [MetricSeries]) -> MetricTimeline {
        let points =
            data
            .filter { $0.name == name }
            .flatMap(\.points)
            .map { ChartPoint<Double>(date: $0.date, value: $0.value) }
            .sorted()

        return MetricTimeline(points: points)
    }
}

#Preview("Counter") {
    NavigationStack {
        MetricSeriesDetailView<Int>(
            name: "checkout.completed",
            telemetry: .counter,
            range: .constant(.today),
            result: .success([
                MetricSeries(
                    name: "checkout.completed",
                    category: Telemetry.Export.counter.rawValue,
                    points: (0..<24).map { hour in
                        MetricSeriesPoint(
                            date: Date().startOfDay.addingTimeInterval(TimeInterval(hour) * .hour),
                            value: Double(40 + hour * 6)
                        )
                    }
                )
            ]),
            resetDates: .success([Date().startOfDay.addingTimeInterval(13 * .hour)])
        )
        .monospacedNavigationTitle(en: "checkout.completed")
    }
}

#Preview("Gauge") {
    NavigationStack {
        MetricSeriesDetailView<Double>(
            name: "queue_depth",
            telemetry: .meter,
            range: .constant(.today),
            result: .success([
                MetricSeries(
                    name: "queue_depth",
                    category: Telemetry.Export.meter.rawValue,
                    points: (0..<24).map { hour in
                        MetricSeriesPoint(
                            date: Date().startOfDay.addingTimeInterval(TimeInterval(hour) * .hour),
                            value: Double(10 + (hour * 7) % 40)
                        )
                    }
                )
            ])
        )
        .monospacedNavigationTitle(en: "queue_depth")
    }
}

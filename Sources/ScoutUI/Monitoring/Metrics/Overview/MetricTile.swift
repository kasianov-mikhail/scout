//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct MetricTile: Identifiable {
    let name: String
    let telemetry: Telemetry.Export
    let value: Double
    let series: [Double]

    var id: String { "\(telemetry.rawValue).\(name)" }

    var suffix: String {
        switch telemetry {
        case .counter, .floatingCounter:
            "total"
        case .timer, .recorder:
            "p50"
        case .meter:
            "latest"
        }
    }

    var valueLabel: String {
        MetricValueFormat(telemetry: telemetry).label(value, compact: true)
    }

    var displayName: String {
        name.replacingOccurrences(of: ".", with: ".\u{200B}")
    }
}

struct MetricTileBuilder {
    let intSeries: [MetricSeries]
    let floatingSeries: [MetricSeries]
    let meterSeries: [MetricSeries]
    let range: Range<Date>
}

extension MetricTileBuilder {
    private static let sliceCount = 12

    var tiles: [MetricTile] {
        var tiles: [MetricTile] = []
        tiles += sumTiles(series: intSeries, telemetry: .counter)
        tiles += sumTiles(series: floatingSeries, telemetry: .floatingCounter)
        tiles += distributionTiles(type: LatencyHistogram.self, telemetry: .timer)
        tiles += distributionTiles(type: RecorderHistogram.self, telemetry: .recorder)
        tiles += meterTiles()

        return tiles.sorted { lhs, rhs in
            let left = Self.rank(lhs.telemetry)
            let right = Self.rank(rhs.telemetry)

            if left != right {
                return left < right
            }
            if lhs.value != rhs.value {
                return lhs.value > rhs.value
            }
            return lhs.name < rhs.name
        }
    }

    private func sumTiles(series: [MetricSeries], telemetry: Telemetry.Export) -> [MetricTile] {
        let slices = range.slices(count: Self.sliceCount)
        let groups = Dictionary(grouping: series.filter { $0.category == telemetry.rawValue }, by: \.name)

        return
            groups
            .map { name, group in
                let points = group.flatMap(\.points).map { ChartPoint<Double>(date: $0.date, value: $0.value) }
                return MetricTile(
                    name: name,
                    telemetry: telemetry,
                    value: points.total(in: range),
                    series: slices.map { points.total(in: $0) }
                )
            }
            .filter { $0.value > 0 }
    }

    private func distributionTiles<H: QuantileHistogram>(type: H.Type, telemetry: Telemetry.Export) -> [MetricTile] {
        let slices = range.slices(count: Self.sliceCount)
        let series = intSeries.filter { item in
            guard let category = item.category else {
                return false
            }
            return type.bucketIndex(of: category) != nil
        }

        return Dictionary(grouping: series, by: \.name).compactMap { name, group in
            let histograms = H.buckets(from: group)
            let combined = histograms.values.reduce(H()) { $0 + $1 }
            guard combined.total > 0 else {
                return nil
            }

            let values = slices.map { slice in
                histograms.filter { slice.contains($0.key) }.values.reduce(H()) { $0 + $1 }.percentile(0.5) ?? 0
            }

            return MetricTile(
                name: name,
                telemetry: telemetry,
                value: combined.percentile(0.5) ?? 0,
                series: values
            )
        }
    }

    private func meterTiles() -> [MetricTile] {
        let slices = range.slices(count: Self.sliceCount)
        let groups = Dictionary(grouping: meterSeries.filter { $0.category == Telemetry.Export.meter.rawValue }, by: \.name)

        return groups.compactMap { name, group in
            let points = group.flatMap(\.points).map { ChartPoint<Double>(date: $0.date, value: $0.value) }

            guard points.contains(where: { range.contains($0.date) }) else {
                return nil
            }

            return MetricTile(
                name: name,
                telemetry: .meter,
                value: points.latest(in: range),
                series: slices.map { points.latest(in: $0) }
            )
        }
    }

    private static func rank(_ telemetry: Telemetry.Export) -> Int {
        switch telemetry {
        case .counter:
            0
        case .floatingCounter:
            1
        case .timer:
            2
        case .recorder:
            3
        case .meter:
            4
        }
    }
}

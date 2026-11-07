//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct ReleaseSeries {
    let sessions: [MetricSeries]
    let crashes: [MetricSeries]
    let hangs: [MetricSeries]
    let installs: [MetricSeries]
    let crashedInstalls: [MetricSeries]
    let exits: [MetricSeries]
    let performance: [MetricSeries]
    let resources: [MetricSeries]

    func report(in range: Range<Date>) -> [ReleaseHealth] {
        let sessionPoints = sessions.points(in: range)
        let sessionCounts = sessionPoints.mapValues(\.total)
        let crashPoints = crashes.points(in: range)
        let hangCounts = hangs.points(in: range).mapValues(\.total)
        let installPoints = installs.points(in: range)
        let installCounts = installPoints.mapValues(\.total)
        let crashedInstallCounts = crashedInstalls.points(in: range).mapValues(\.total)
        let exitCounts = exits.reasonCounts(in: range)
        let resourceCounts = resources.kindCounts(in: range)
        let summaries = Dictionary(grouping: performance, by: \.version).mapValues {
            PerformanceSummary(series: $0, range: range)
        }

        let versions = Set(sessionCounts.keys)
            .union(crashPoints.keys)
            .union(installCounts.keys)
            .sorted(by: versionDescending)

        let totalSessions = sessionCounts.values.reduce(0, +)

        return versions.enumerated().map { index, version in
            let sessions = sessionCounts[version] ?? 0
            let crashSeries = crashPoints[version] ?? []
            let crashes = crashSeries.total
            let installs = installCounts[version] ?? 0
            let previous = versions[(index + 1)...].lazy
                .compactMap { version in summaries[version].map { PerformanceComparison.VersionSummary(version: version, summary: $0) } }
                .first { !$0.summary.isEmpty }

            let released =
                [sessionPoints[version], crashPoints[version], installPoints[version]]
                .compactMap(\.self)
                .joined()
                .map(\.date)
                .min() ?? range.lowerBound

            return ReleaseHealth(
                id: version,
                released: released,
                freeSessions: Stability(of: crashes, in: sessions),
                freeUsers: Stability.optional(of: crashedInstallCounts[version] ?? 0, in: installs),
                crashes: crashes,
                hangs: hangCounts[version] ?? 0,
                sessions: sessions,
                adoption: Adoption(of: sessions, in: totalSessions),
                exits: ExitSummary(counts: exitCounts[version] ?? [:]),
                performance: PerformanceComparison(current: summaries[version] ?? PerformanceSummary(), previous: previous),
                resources: ResourceSummary(counts: resourceCounts[version] ?? [:])
            )
        }
    }
}

extension [MetricSeries] {
    fileprivate func points(in range: Range<Date>) -> [String: [ChartPoint<Int>]] {
        var result: [String: [ChartPoint<Int>]] = [:]
        for series in self {
            if let version = series.version {
                let points: [ChartPoint<Int>] = series.chartPoints()
                result[version, default: []] += points.filter { range.contains($0.date) }
            }
        }
        return result
    }
}

extension [MetricSeries] {
    fileprivate func reasonCounts(in range: Range<Date>) -> [String: [ExitReason: Int]] {
        var result: [String: [ExitReason: Int]] = [:]
        for series in self {
            if let version = series.version, let reason = series.category.flatMap(ExitReason.init(rawValue:)) {
                let points: [ChartPoint<Int>] = series.chartPoints()
                result[version, default: [:]][reason, default: 0] += points.filter { range.contains($0.date) }.total
            }
        }
        return result
    }
}

extension [MetricSeries] {
    fileprivate func kindCounts(in range: Range<Date>) -> [String: [ResourceKind: Int]] {
        var result: [String: [ResourceKind: Int]] = [:]
        for series in self {
            if let version = series.version, let kind = series.category.flatMap(ResourceKind.init(rawValue:)) {
                let points: [ChartPoint<Int>] = series.chartPoints()
                result[version, default: [:]][kind, default: 0] += points.filter { range.contains($0.date) }.total
            }
        }
        return result
    }
}

private func versionDescending(_ lhs: String, _ rhs: String) -> Bool {
    let lhsParts = lhs.split(separator: ".").map { Int($0) ?? 0 }
    let rhsParts = rhs.split(separator: ".").map { Int($0) ?? 0 }

    for index in 0..<max(lhsParts.count, rhsParts.count) {
        let left = index < lhsParts.count ? lhsParts[index] : 0
        let right = index < rhsParts.count ? rhsParts[index] : 0
        if left != right {
            return left > right
        }
    }

    return lhs > rhs
}

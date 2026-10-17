//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct PerformanceComparison: Equatable {
    let current: PerformanceSummary
    let previous: VersionSummary?

    struct VersionSummary: Equatable {
        let version: String
        let summary: PerformanceSummary
    }
}

extension PerformanceComparison {
    func change(_ value: KeyPath<PerformanceSummary, Double?>) -> Double? {
        guard let now = current[keyPath: value], let before = previous?.summary[keyPath: value] else {
            return nil
        }
        guard before > 0 else {
            return nil
        }
        return now / before - 1
    }

    var readouts: [PerformanceReadout] {
        [
            PerformanceReadout(
                title: "Launch time",
                value: current.launchTime.map { String(format: "%.0f ms", $0) },
                change: change(\.launchTime)
            ),
            PerformanceReadout(
                title: "Hang rate",
                value: current.hangRate.map { String(format: "%.1f s/h", $0) },
                change: change(\.hangRate)
            ),
            PerformanceReadout(
                title: "Peak memory",
                value: current.peakMemory.map { String(format: "%.0f MB", $0) },
                change: change(\.peakMemory)
            ),
        ]
    }

    func launchBars(version: String) -> [LaunchBar] {
        let versions = [VersionSummary(version: version, summary: current)] + [previous].compactMap(\.self)
        let last = versions.compactMap { $0.summary.launchHistogram.counts.lastIndex { $0 > 0 } }.max() ?? 0
        let shown = min(last, launchBarLimit - 1)

        return versions.flatMap { item in
            let histogram = item.summary.launchHistogram
            return (0...shown).map { index in
                LaunchBar(
                    version: item.version,
                    start: index * PerformanceMetric.launchStep,
                    share: histogram.total > 0 ? Double(histogram.counts[index]) / Double(histogram.total) : 0
                )
            }
        }
    }
}

extension PerformanceComparison {
    static var sample: PerformanceComparison {
        var previous = PerformanceSummary.sample
        previous.hangMilliseconds = 7_900
        return PerformanceComparison(current: .sample, previous: VersionSummary(version: "3.1.4", summary: previous))
    }
}

struct PerformanceReadout: Identifiable {
    let title: String
    let value: String?
    let change: Double?

    var id: String {
        title
    }

    var color: Color {
        switch change {
        case .some(0.1...): .orange
        case .some(...(-0.1)): .green
        default: .primary
        }
    }
}

struct LaunchBar: Identifiable {
    let version: String
    let start: Int
    let share: Double

    var id: String {
        "\(version)-\(start)"
    }

    var category: String {
        String(start)
    }

    static func axisLabel(category: String) -> String? {
        guard let start = Int(category) else {
            return nil
        }
        guard start % 500 == 0 else {
            return nil
        }
        return String(format: "%.1f s", Double(start) / 1_000)
    }
}

private let launchBarLimit = 30

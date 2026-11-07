//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

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
}

extension PerformanceComparison {
    static var sample: PerformanceComparison {
        var previous = PerformanceSummary.sample
        previous.hangMilliseconds = 7_900
        return PerformanceComparison(current: .sample, previous: VersionSummary(version: "3.1.4", summary: previous))
    }
}

struct PerformanceReadout {
    let title: String
    let value: String?
    let change: Double?
}

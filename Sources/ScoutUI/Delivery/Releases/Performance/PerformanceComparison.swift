//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

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
}

extension PerformanceComparison {
    static var sample: PerformanceComparison {
        var previous = PerformanceSummary.sample
        previous.hangMilliseconds = 7_900
        return PerformanceComparison(current: .sample, previous: VersionSummary(version: "3.1.4", summary: previous))
    }
}

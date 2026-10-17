//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

struct PerformanceComparison: Equatable {
    let current: PerformanceSummary
    let previous: PerformanceSummary?
}

extension PerformanceComparison {
    func change(_ value: KeyPath<PerformanceSummary, Double?>) -> Double? {
        guard let now = current[keyPath: value], let before = previous?[keyPath: value] else {
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
        PerformanceComparison(current: .sample, previous: .sample)
    }
}

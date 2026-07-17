//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

package enum LatencyBuckets {
    package static let boundsMilliseconds = [1, 2, 5, 10, 25, 50, 100, 250, 500, 1_000, 2_500, 5_000, 10_000, 30_000]

    private static let categoryPrefix = "timer_le_"
    private static let overflowSuffix = "inf"

    package static let categories =
        boundsMilliseconds.map { categoryPrefix + String($0) } + [categoryPrefix + overflowSuffix]

    static func category(for seconds: TimeInterval) -> String {
        let milliseconds = seconds * 1_000
        guard let bound = boundsMilliseconds.first(where: { milliseconds <= Double($0) }) else {
            return categoryPrefix + overflowSuffix
        }
        return categoryPrefix + String(bound)
    }

    static func upperBound(of category: String) -> TimeInterval? {
        guard category.hasPrefix(categoryPrefix) else { return nil }
        guard let milliseconds = Int(category.dropFirst(categoryPrefix.count)) else {
            return nil
        }
        return TimeInterval(milliseconds) / 1_000
    }

    package static func index(of category: String) -> Int? {
        categories.firstIndex(of: category)
    }
}

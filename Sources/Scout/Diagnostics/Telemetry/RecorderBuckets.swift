//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

package enum RecorderBuckets {
    package static let bounds = [
        1, 2, 5, 10, 20, 50, 100, 200, 500, 1_000, 2_000, 5_000, 10_000, 20_000, 50_000, 100_000, 200_000, 500_000,
        1_000_000,
    ]

    private static let categoryPrefix = "recorder_le_"
    private static let overflowSuffix = "inf"

    package static let categories = bounds.map { categoryPrefix + String($0) } + [categoryPrefix + overflowSuffix]

    static func category(for value: Double) -> String {
        guard let bound = bounds.first(where: { value <= Double($0) }) else {
            return categoryPrefix + overflowSuffix
        }
        return categoryPrefix + String(bound)
    }

    static func upperBound(of category: String) -> Double? {
        guard category.hasPrefix(categoryPrefix) else { return nil }
        guard let value = Int(category.dropFirst(categoryPrefix.count)) else {
            return nil
        }
        return Double(value)
    }

    package static func index(of category: String) -> Int? {
        categories.firstIndex(of: category)
    }
}

//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol Combining {
    associatedtype MergeKey: Hashable

    /// Identifies values that combine: two values are duplicates iff their keys are equal.
    var mergeKey: MergeKey { get }
    static func + (lhs: Self, rhs: Self) -> Self
}

extension Combining {
    func isDuplicate(of other: Self) -> Bool {
        mergeKey == other.mergeKey
    }

    static func += (lhs: inout Self, rhs: Self) {
        assert(lhs.isDuplicate(of: rhs), "Cannot combine non-duplicate instances of \(Self.self)")
        lhs = lhs + rhs
    }
}

extension Array where Element: Combining {
    // Groups by mergeKey in one pass (O(n)) instead of scanning the accumulated
    // result per element, while preserving each key's first-occurrence order.
    func mergeDuplicates() -> Self {
        var order: [Element.MergeKey] = []
        var merged: [Element.MergeKey: Element] = [:]

        for value in self {
            let key = value.mergeKey
            if let existing = merged[key] {
                merged[key] = existing + value
            } else {
                merged[key] = value
                order.append(key)
            }
        }

        return order.map { merged[$0]! }
    }
}

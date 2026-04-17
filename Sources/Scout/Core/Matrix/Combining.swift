//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A value that can be merged pairwise with an "equivalent" instance.
///
/// `isDuplicate(of:)` answers whether two values refer to the same bucket
/// (e.g. same matrix coordinate); `+` combines them. `Array.mergeDuplicates`
/// uses both to collapse a sequence down to one entry per bucket.
///
protocol Combining {
    func isDuplicate(of other: Self) -> Bool
    static func + (lhs: Self, rhs: Self) -> Self
}

extension Combining {
    static func += (lhs: inout Self, rhs: Self) {
        assert(lhs.isDuplicate(of: rhs), "Cannot combine non-duplicate instances of \(Self.self)")
        lhs = lhs + rhs
    }
}

extension Array where Element: Combining {
    func mergeDuplicates() -> Self {
        reduce(into: []) { result, value in
            if let index = result.firstIndex(where: {
                $0.isDuplicate(of: value)
            }) {
                result[index] += value
            } else {
                result.append(value)
            }
        }
    }
}

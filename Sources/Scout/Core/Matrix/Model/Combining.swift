//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A value that can be merged pairwise with an "equivalent" instance.
///
/// `duplicateKey` identifies whether two values refer to the same bucket
/// (e.g. same matrix coordinate); `+` combines them. `Array.mergeDuplicates`
/// uses both to collapse a sequence down to one entry per bucket in O(n).
///
protocol Combining {
    associatedtype DuplicateKey: Hashable
    var duplicateKey: DuplicateKey { get }
    func isDuplicate(of other: Self) -> Bool
    static func + (lhs: Self, rhs: Self) -> Self
}

extension Combining {
    func isDuplicate(of other: Self) -> Bool {
        duplicateKey == other.duplicateKey
    }

    static func += (lhs: inout Self, rhs: Self) {
        assert(lhs.isDuplicate(of: rhs), "Cannot combine non-duplicate instances of \(Self.self)")
        lhs = lhs + rhs
    }
}

extension Array where Element: Combining {
    func mergeDuplicates() -> Self {
        var indexByKey: [Element.DuplicateKey: Int] = [:]

        return reduce(into: []) { result, value in
            if let index = indexByKey[value.duplicateKey] {
                result[index] += value
            } else {
                indexByKey[value.duplicateKey] = result.endIndex
                result.append(value)
            }
        }
    }
}

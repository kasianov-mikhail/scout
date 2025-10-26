//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

protocol HasCount {
    associatedtype Count: AdditiveArithmetic
    var count: Count { get }
}

extension Collection where Element: HasCount {
    var total: Element.Count {
        map(\.count).reduce(.zero, +)
    }
}

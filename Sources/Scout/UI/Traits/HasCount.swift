//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol HasCount {
    associatedtype Value: AdditiveArithmetic
    var count: Value { get }
}

extension Collection where Element: HasCount {
    var total: Element.Value {
        map(\.count).reduce(.zero, +)
    }
}

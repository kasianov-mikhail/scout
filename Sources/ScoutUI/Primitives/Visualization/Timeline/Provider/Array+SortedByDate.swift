//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Array {
    func sorted(byDate keyPath: KeyPath<Element, Date?>, ascending: Bool = true) -> [Element] {
        sorted {
            let lhs = $0[keyPath: keyPath] ?? .distantPast
            let rhs = $1[keyPath: keyPath] ?? .distantPast
            return ascending ? lhs < rhs : lhs > rhs
        }
    }
}

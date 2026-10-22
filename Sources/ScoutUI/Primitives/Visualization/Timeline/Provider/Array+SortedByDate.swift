//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Array {
    func sorted(byDate keyPath: KeyPath<Element, Date?>) -> [Element] {
        sorted {
            ($0[keyPath: keyPath] ?? .distantPast) < ($1[keyPath: keyPath] ?? .distantPast)
        }
    }
}

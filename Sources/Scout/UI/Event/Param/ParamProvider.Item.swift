//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ParamProvider {
    struct Item: Identifiable, Comparable, Hashable, CustomStringConvertible {
        let id = UUID()
        let key: String
        let value: String

        static func fromData(_ data: Data) throws -> [Item] {
            try JSONDecoder().decode([String: String].self, from: data).map(Item.init)
        }

        static func < (lhs: Item, rhs: Item) -> Bool {
            lhs.key < rhs.key
        }

        var description: String {
            "\(key): \(value)"
        }
    }
}

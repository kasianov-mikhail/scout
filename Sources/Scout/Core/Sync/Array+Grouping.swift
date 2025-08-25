//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Array {
    func grouped(by keyPath: KeyPath<Element, Date?>) -> [String: Int] {
        Dictionary(grouping: self) {
            $0[keyPath: keyPath]
        }
        .reduce(into: [:]) { result, pair in
            if let key = pair.key {
                let week = Calendar.UTC.component(.weekday, from: key)
                let hour = Calendar.UTC.component(.hour, from: key)
                let components = ["cell", String(week), String(format: "%02d", hour)]
                let joined = components.joined(separator: "_")

                result[joined] = pair.value.count
            }
        }
    }
}

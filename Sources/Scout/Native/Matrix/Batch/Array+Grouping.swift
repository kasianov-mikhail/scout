//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Array {
    func grouped(by keyPath: KeyPath<Element, Date?>) -> [String: [Element]] {
        reduce(into: [:]) { result, element in
            guard let date = element[keyPath: keyPath] else {
                return
            }
            let week = Calendar.utc.component(.weekday, from: date)
            let hour = Calendar.utc.component(.hour, from: date)
            result["cell_\(week)_\(hour.leadingZero)", default: []].append(element)
        }
    }
}

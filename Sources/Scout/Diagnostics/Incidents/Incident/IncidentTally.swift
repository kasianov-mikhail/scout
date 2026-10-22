//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct IncidentTally: Equatable, Sendable {
    package let fingerprint: String
    package let name: String
    package let count: Int
    package let firstHour: Date

    package init(fingerprint: String, name: String, count: Int, firstHour: Date) {
        self.fingerprint = fingerprint
        self.name = name
        self.count = count
        self.firstHour = firstHour
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct IncidentIndex: Equatable, Sendable {
    package let tallies: [IncidentTally]

    /// The hours that hold records written before the aggregate keyed them,
    /// which only a raw read can name.
    package let unkeyed: Range<Date>?

    package init(tallies: [IncidentTally], unkeyed: Range<Date>?) {
        self.tallies = tallies
        self.unkeyed = unkeyed
    }
}

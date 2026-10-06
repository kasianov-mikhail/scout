//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

struct DateAddTests {
    let base = Date(timeIntervalSinceReferenceDate: 0)

    @Test("addingMonth adds one month by default")
    func addingMonthDefault() {
        let result = base.addingMonth()
        let components = Calendar.utc.dateComponents([.month], from: base, to: result)
        #expect(components.month == 1)
    }

    @Test("adding generic component works")
    func addingGeneric() {
        let result = base.adding(.minute, value: 30)
        #expect(result.timeIntervalSince(base) == 1800)
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

struct LogCategoryTests {
    @Test("Only crashes and hangs read a rise as bad")
    func risesAreBad() {
        let categories = LogCategory.allCases.filter(\.risesAreBad)

        #expect(categories == [.crashes, .hangs])
    }
}

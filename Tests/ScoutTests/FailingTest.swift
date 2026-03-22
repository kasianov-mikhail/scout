//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

struct FailingTest {
    @Test("This test should fail") func fail() {
        #expect(1 == 2)
    }
}

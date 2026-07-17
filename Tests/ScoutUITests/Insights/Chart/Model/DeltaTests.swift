//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport
@testable import ScoutUI

struct DeltaTests {
    @Test("Growth is a positive fraction")
    func growth() throws {
        let delta = try #require(Delta(current: 112, previous: 100))

        #expect(delta.value == 0.12)
        #expect(delta.isPositive)
        #expect(delta.formatted == "+12%")
    }

    @Test("Decline is a negative fraction")
    func decline() throws {
        let delta = try #require(Delta(current: 86, previous: 100))

        #expect(delta.value == -0.14)
        #expect(!delta.isPositive)
        #expect(delta.formatted == "-14%")
    }

    @Test("Standing still reads as a positive zero")
    func unchanged() throws {
        let delta = try #require(Delta(current: 100, previous: 100))

        #expect(delta.value == 0)
        #expect(delta.isPositive)
        #expect(delta.formatted == "+0%")
    }

    @Test("An empty previous period has nothing to compare against")
    func emptyPrevious() {
        #expect(Delta(current: 42, previous: 0) == nil)
        #expect(Delta(current: 0, previous: 0) == nil)
    }

    @Test("Dropping to nothing is a full decline")
    func droppedToZero() throws {
        let delta = try #require(Delta(current: 0, previous: 50))

        #expect(delta.value == -1)
        #expect(delta.formatted == "-100%")
    }
}

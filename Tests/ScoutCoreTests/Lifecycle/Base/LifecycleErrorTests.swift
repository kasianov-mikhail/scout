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

struct LifecycleErrorTests {
    @Test("notFound equals notFound")
    func notFoundEquality() {
        #expect(LifecycleError.notFound == LifecycleError.notFound)
    }

    @Test("alreadyCompleted equals alreadyCompleted regardless of date")
    func alreadyCompletedEquality() {
        let date1 = Date(timeIntervalSinceReferenceDate: 0)
        let date2 = Date(timeIntervalSinceReferenceDate: 1000)
        #expect(LifecycleError.alreadyCompleted(date1) == LifecycleError.alreadyCompleted(date2))
    }

    @Test("notFound does not equal alreadyCompleted")
    func differentCasesNotEqual() {
        let date = Date()
        #expect(LifecycleError.notFound != LifecycleError.alreadyCompleted(date))
    }

    @Test("notFound description contains 'not found'")
    func notFoundDescription() {
        let description = LifecycleError.notFound.errorDescription
        #expect(description?.contains("not found") == true)
    }

    @Test("alreadyCompleted description contains 'already completed'")
    func alreadyCompletedDescription() {
        let date = Date(timeIntervalSinceReferenceDate: 0)
        let description = LifecycleError.alreadyCompleted(date).errorDescription
        #expect(description?.contains("already completed") == true)
    }

    @Test("LifecycleError conforms to LocalizedError")
    func conformsToLocalizedError() {
        let error: any LocalizedError = LifecycleError.notFound
        #expect(error.errorDescription != nil)
    }
}

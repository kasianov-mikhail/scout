//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct MonitorErrorTests {
    // MARK: - Equality

    @Test("notFound equals notFound")
    func notFoundEquality() {
        #expect(MonitorError.notFound == MonitorError.notFound)
    }

    @Test("alreadyCompleted equals alreadyCompleted regardless of date")
    func alreadyCompletedEquality() {
        let date1 = Date(timeIntervalSinceReferenceDate: 0)
        let date2 = Date(timeIntervalSinceReferenceDate: 1000)
        #expect(MonitorError.alreadyCompleted(date1) == MonitorError.alreadyCompleted(date2))
    }

    @Test("notFound does not equal alreadyCompleted")
    func differentCasesNotEqual() {
        let date = Date()
        #expect(MonitorError.notFound != MonitorError.alreadyCompleted(date))
    }

    // MARK: - Error description

    @Test("notFound description contains 'not found'")
    func notFoundDescription() {
        let description = MonitorError.notFound.errorDescription
        #expect(description?.contains("not found") == true)
    }

    @Test("alreadyCompleted description contains 'already completed'")
    func alreadyCompletedDescription() {
        let date = Date(timeIntervalSinceReferenceDate: 0)
        let description = MonitorError.alreadyCompleted(date).errorDescription
        #expect(description?.contains("already completed") == true)
    }

    @Test("MonitorError conforms to LocalizedError")
    func conformsToLocalizedError() {
        let error: any LocalizedError = MonitorError.notFound
        #expect(error.errorDescription != nil)
    }
}

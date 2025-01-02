//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing
import UIKit
import XCTest

@testable import Scout

struct NotificationListenerTests {

    @Test("Success setup") func testSuccessSetup() async throws {
        let listener = NotificationListener(table: [:])
        #expect(throws: Never.self) {
            try listener.setup()
        }
    }

    @Test("Failure setup") func testFailureSetup() async throws {
        let listener = NotificationListener(table: [:])
        #expect(throws: NotificationListener.Error.alreadySetup) {
            try listener.setup()
            try listener.setup()
        }
    }
}

class NotificationListenerTestCase: XCTestCase {

    // Special case not covering with SwiftTesting
    func testNotificationHandling() async throws {
        let expectation = XCTestExpectation(description: "Notification handling")
        let listener = NotificationListener(table: [
            UIApplication.didBecomeActiveNotification: expectation.fulfill
        ])
        try listener.setup()
        NotificationCenter.default.post(
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        await fulfillment(of: [expectation], timeout: 0.1)
    }
}

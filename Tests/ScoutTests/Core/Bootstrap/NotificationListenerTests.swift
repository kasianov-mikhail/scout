//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import XCTest

@testable import Scout

class NotificationListenerTestCase: XCTestCase {
    // Special case not covering with SwiftTesting
    func testNotificationHandling() async throws {
        let expectation = XCTestExpectation(description: "Notification handling")
        let listener = NotificationListener(table: [
            UIApplication.didBecomeActiveNotification: expectation.fulfill
        ])
        listener.observe()
        NotificationCenter.default.post(
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        await fulfillment(of: [expectation], timeout: 0.1)
    }
}

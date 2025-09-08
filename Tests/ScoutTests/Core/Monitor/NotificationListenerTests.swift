//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing
import UIKit

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
        #expect(throws: NotificationListener.SetupError.self) {
            try listener.setup()
            try listener.setup()
        }
    }
}

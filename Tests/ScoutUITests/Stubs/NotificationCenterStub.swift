//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import UserNotifications

@testable import ScoutUI

final class NotificationCenterStub: AlertNotificationCenter, @unchecked Sendable {
    private let lock = NSLock()
    private var grantedStorage = true
    private var authorizationStorage = 0
    private var requestStorage: [UNNotificationRequest] = []

    var granted: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return grantedStorage
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            grantedStorage = newValue
        }
    }

    var authorizationRequests: Int {
        lock.lock()
        defer { lock.unlock() }
        return authorizationStorage
    }

    var requests: [UNNotificationRequest] {
        lock.lock()
        defer { lock.unlock() }
        return requestStorage
    }

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        recordAuthorization()
    }

    func add(_ request: UNNotificationRequest) async throws {
        record(request)
    }

    private func recordAuthorization() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        authorizationStorage += 1
        return grantedStorage
    }

    private func record(_ request: UNNotificationRequest) {
        lock.lock()
        defer { lock.unlock() }
        requestStorage.append(request)
    }
}

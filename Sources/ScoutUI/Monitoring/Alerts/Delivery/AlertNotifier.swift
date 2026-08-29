//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UserNotifications

protocol AlertNotificationCenter: Sendable {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func add(_ request: UNNotificationRequest) async throws
    func authorizationStatus() async -> UNAuthorizationStatus
}

// UNUserNotificationCenter is documented thread-safe but not annotated Sendable in the SDK.
extension UNUserNotificationCenter: @retroactive @unchecked Sendable {}

extension UNUserNotificationCenter: AlertNotificationCenter {
    func authorizationStatus() async -> UNAuthorizationStatus {
        await notificationSettings().authorizationStatus
    }
}

struct AlertNotifier {
    let center: AlertNotificationCenter

    init(center: AlertNotificationCenter = UNUserNotificationCenter.current()) {
        self.center = center
    }

    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func refusesNotifications() async -> Bool {
        await center.authorizationStatus() == .denied
    }

    @discardableResult
    func deliver(_ statuses: [AlertStatus]) async -> Set<AlertRule> {
        var undelivered: Set<AlertRule> = []

        for status in statuses {
            guard let message = AlertMessage(status: status) else {
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = message.title
            content.body = message.body
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil
            )

            do {
                try await center.add(request)
            } catch {
                undelivered.insert(status.rule)
            }
        }

        return undelivered
    }
}

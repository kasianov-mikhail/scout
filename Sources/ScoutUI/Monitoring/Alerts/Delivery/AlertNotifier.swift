//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UserNotifications

struct AlertNotifier {
    let center: AlertNotificationCenter

    init(center: AlertNotificationCenter = UNUserNotificationCenter.current()) {
        self.center = center
    }

    func needsAuthorization() async -> Bool {
        await center.authorizationStatus() == .notDetermined
    }

    func requestAuthorization() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func refusesNotifications() async -> Bool {
        await center.authorizationStatus() == .denied
    }

    @discardableResult
    func deliver(_ statuses: [AlertStatus]) async -> [AlertStatus] {
        var undelivered: [AlertStatus] = []

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
                undelivered.append(status)
            }
        }

        return undelivered
    }
}

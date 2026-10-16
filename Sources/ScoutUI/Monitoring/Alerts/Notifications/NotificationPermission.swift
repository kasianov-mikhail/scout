//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UserNotifications

struct NotificationPermission {
    private let center: AlertNotificationCenter

    init(center: AlertNotificationCenter) {
        self.center = center
    }

    var isDenied: Bool {
        get async {
            await center.authorizationStatus() == .denied
        }
    }

    func requestIfUndetermined() async {
        guard await center.authorizationStatus() == .notDetermined else {
            return
        }
        do {
            _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Failed to request notification authorization: \(error)")
        }
    }
}

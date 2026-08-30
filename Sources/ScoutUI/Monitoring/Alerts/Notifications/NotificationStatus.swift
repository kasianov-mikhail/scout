//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func notificationStatus(of provider: AlertProvider) -> some View {
        modifier(NotificationStatusModifier(provider: provider))
    }
}

private struct NotificationStatusModifier: ViewModifier {
    let provider: AlertProvider

    func body(content: Content) -> some View {
        content.task {
            await provider.refreshNotificationStatus()

            for await _ in NotificationCenter.default.notifications(named: AppLifecycle.willEnterForeground) {
                await provider.refreshNotificationStatus()
            }
        }
    }
}

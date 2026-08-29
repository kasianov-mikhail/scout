//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func refreshingNotificationStatus(of provider: AlertProvider) -> some View {
        modifier(RefreshingNotificationStatusModifier(provider: provider))
    }
}

private struct RefreshingNotificationStatusModifier: ViewModifier {
    let provider: AlertProvider

    func body(content: Content) -> some View {
        content
            .task {
                await provider.refreshNotificationStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: AppLifecycle.willEnterForeground)) { _ in
                Task { await provider.refreshNotificationStatus() }
            }
    }
}

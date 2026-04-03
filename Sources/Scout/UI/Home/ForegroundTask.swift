//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI
import UIKit

extension View {
    func foregroundTask(action: @escaping () async -> Void) -> some View {
        modifier(ForegroundTaskModifier(action: action))
    }
}

private struct ForegroundTaskModifier: ViewModifier {
    let action: () async -> Void

    func body(content: Content) -> some View {
        content
            .task {
                await action()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await action()
                }
            }
    }
}

//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

extension NotificationListener {
    @MainActor static func appState(sync: @escaping SyncAction) -> NotificationListener {
        NotificationListener(table: [
            UIApplication.willEnterForegroundNotification: {
                IDs.session = UUID()

                try await persistentContainer.performBackgroundTasks(
                    SessionObject.trigger,
                    UserActivityObject.trigger
                )
                try await sync()
            },
            UIApplication.didEnterBackgroundNotification: {
                try await persistentContainer.performBackgroundTasks(
                    SessionObject.complete,
                    LaunchObject.complete,
                    UserActivityObject.trigger
                )
                try await sync()
            },
        ])
    }
}

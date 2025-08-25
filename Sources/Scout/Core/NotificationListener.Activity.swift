//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

extension NotificationListener {
    @MainActor public static let activity = NotificationListener(table: [
        UIApplication.willEnterForegroundNotification: {
            try await persistentContainer.performBackgroundTask(SessionObject.trigger)
            try await persistentContainer.performBackgroundTask(UserActivity.trigger)
            try await sync(in: container)
        },
        UIApplication.didEnterBackgroundNotification: {
            try await persistentContainer.performBackgroundTask(SessionObject.complete)
            try await persistentContainer.performBackgroundTask(UserActivity.trigger)
            try await sync(in: container)
        }
    ])
}

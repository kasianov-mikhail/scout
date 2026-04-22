//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

extension ActionTable {
    static let appState = ActionTable(actions: [
        UIApplication.willEnterForegroundNotification: {
            IDs.session = UUID()
            try await persistentContainer.performBackgroundTasks(
                SessionObject.trigger,
                UserActivityObject.trigger
            )
        },
        UIApplication.didEnterBackgroundNotification: {
            try await persistentContainer.performBackgroundTasks(
                SessionObject.complete,
                LaunchObject.complete,
                UserActivityObject.trigger
            )
        },
    ])
}

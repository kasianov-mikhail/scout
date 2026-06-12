//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ActionTable {
    static let appState = ActionTable(actions: [
        AppLifecycle.willEnterForeground: {
            try await persistentContainer.performBackgroundTasks(
                SessionObject.trigger,
                UserActivityObject.trigger
            )
        },
        AppLifecycle.didEnterBackground: {
            try await persistentContainer.performBackgroundTasks(
                SessionObject.complete,
                UserActivityObject.trigger
            )
        },
    ])
}

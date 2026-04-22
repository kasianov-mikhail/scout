//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

class NotificationListener {
    typealias Action = @Sendable () async throws -> Void
    typealias ActionTable = [Notification.Name: Action]

    private let table: ActionTable

    init(table: ActionTable) {
        self.table = table
    }

    func observe() {
        for (name, action) in table {
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { _ in
                Task(operation: action)
            }
        }
    }
}

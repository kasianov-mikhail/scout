//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData
import UIKit

class NotificationListener {
    struct SetupError: LocalizedError {
        let errorDescription: String? = "NotificationListener is already setup"
    }

    typealias Action = @Sendable () async throws -> Void
    typealias ActionTable = [Notification.Name: Action]

    private let table: ActionTable
    private var isSetup = false

    init(table: ActionTable) {
        self.table = table
    }

    func setup() throws {
        guard !isSetup else {
            throw SetupError()
        }

        isSetup = true
        table.observe()
    }
}

extension NotificationListener.ActionTable {
    fileprivate func observe() {
        for (name, action) in self {
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { _ in
                Task(operation: action)
            }
        }
    }
}

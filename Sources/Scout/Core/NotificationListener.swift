//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import UIKit

public actor NotificationListener {

    typealias Action = @Sendable () async throws -> Void
    typealias ActionTable = [Notification.Name: Action]

    private let table: ActionTable

    init(table: ActionTable) {
        self.table = table
    }

    // MARK: - Shared Instance

     public static let activity = NotificationListener(table: [
         UIApplication.didBecomeActiveNotification: {
             try await persistentContainer.performBackgroundTask(SessionMonitor.trigger)
         },
         UIApplication.willResignActiveNotification: {
             try await persistentContainer.performBackgroundTask(SessionMonitor.complete)
         },
     ])

    // MARK: - Error

    enum Error: LocalizedError {
        case alreadySetup

        var errorDescription: String? {
            switch self {
            case .alreadySetup:
                return "ActivityListener is already setup"
            }
        }
    }

    // MARK: - Setup

    private var isSetup = false

    public func setup() throws {
        guard !isSetup else {
            throw Error.alreadySetup
        }

        isSetup = true

        observeTable()
    }

    private func observeTable() {
        for (name, action) in table {
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { _ in
                Task {
                    do {
                        try await action()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

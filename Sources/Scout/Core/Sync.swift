//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

public func sync(in container: CKContainer?) async throws {
    guard let container else {
        throw SyncError.containerNotFound
    }
    guard try await container.accountStatus() == .available else {
        throw SyncError.notLoggedIn
    }

    try await SyncDriver(
        database: container.publicCloudDatabase,
        context: persistentContainer.viewContext
    )
    .execute()
}

enum SyncError: Error {
    case containerNotFound
    case notLoggedIn

    var localizedDescription: String {
        switch self {
        case .containerNotFound:
            "CloudKit container not found. Call `setup(container:)` while initializing the app."
        case .notLoggedIn:
            "User is not logged in to iCloud"
        }
    }
}

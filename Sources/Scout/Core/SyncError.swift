//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// An error type that represents a synchronization error.
enum SyncError: Error {

    /// The CloudKit container was not found.
    case containerNotFound

    /// The user is not logged in to iCloud.
    case notLoggedIn

    var localizedDescription: String {
        switch self {
        case .containerNotFound:
            return
                "CloudKit container not found. Call `setup(container:)` while initializing the app."
        case .notLoggedIn:
            return "User is not logged in to iCloud"
        }
    }
}

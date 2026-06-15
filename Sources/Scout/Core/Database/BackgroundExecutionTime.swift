//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if os(iOS)
    import UIKit
#else
    import Foundation
#endif

/// The minimum background execution time, in seconds, that must remain before
/// Scout starts a new database request.
private let minimumBackgroundTime: TimeInterval = 15

/// Throws ``InsufficientBackgroundTimeError`` when too little background
/// execution time remains to safely start a database request.
///
/// Every backend gates its requests on this so an upload or read isn't started
/// only to be stranded when iOS suspends the app — CloudKit through its request
/// runner and hosted servers through ``HTTPDatabase``. It is a no-op anywhere
/// but iOS, where apps keep running in the background and the remaining time is
/// effectively unbounded.
///
func requireBackgroundTime() async throws {
    #if os(iOS)
        guard await UIApplication.shared.backgroundTimeRemaining > minimumBackgroundTime else {
            throw InsufficientBackgroundTimeError()
        }
    #endif
}

/// Raised when a database request is skipped because too little background
/// execution time remains.
///
struct InsufficientBackgroundTimeError: LocalizedError {
    let errorDescription: String? = "The operation was aborted because the remaining background time is insufficient."
    let failureReason: String? = "Not enough background time remaining."
    let helpAnchor: String? = "https://developer.apple.com/documentation/uikit/uiapplication/backgroundtimeremaining"
    let recoverySuggestion: String? = "Try again later."
}

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

private let minimumBackgroundTime: TimeInterval = 15

package func requireBackgroundTime() async throws {
    #if os(iOS)
        guard await UIApplication.shared.backgroundTimeRemaining > minimumBackgroundTime else {
            throw InsufficientBackgroundTimeError()
        }
    #endif
}

struct InsufficientBackgroundTimeError: LocalizedError {
    let errorDescription: String? = "The operation was aborted because the remaining background time is insufficient."
    let failureReason: String? = "Not enough background time remaining."
    let helpAnchor: String? = "https://developer.apple.com/documentation/uikit/uiapplication/backgroundtimeremaining"
    let recoverySuggestion: String? = "Try again later."
}

// The window closed before the request went out, so no backend ever saw the
// records: charging them an attempt would abandon data nothing rejected.
extension InsufficientBackgroundTimeError: TransientFailure {
    var isTransient: Bool {
        true
    }
}

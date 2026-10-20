//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

#if os(iOS)
    import UIKit
#else
    import Foundation
#endif

private let minimumBackgroundTime: TimeInterval = 15

func requireBackgroundTime() async throws {
    #if os(iOS)
        let isStarved = await MainActor.run {
            UIApplication.shared.applicationState == .background && UIApplication.shared.backgroundTimeRemaining <= minimumBackgroundTime
        }
        guard !isStarved else {
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

extension InsufficientBackgroundTimeError: TransientFailure {
    var isTransient: Bool {
        true
    }
}

//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum LifecycleError: LocalizedError, Equatable {
    case notFound
    case alreadyCompleted(Date)

    var errorDescription: String? {
        switch self {
        case .notFound:
            "LifecycleError not found in the context"
        case .alreadyCompleted(let date):
            "LifecycleError already completed on \(date)"
        }
    }

    static func == (lhs: LifecycleError, rhs: LifecycleError) -> Bool {
        switch (lhs, rhs) {
        case (.notFound, .notFound):
            true
        case (.alreadyCompleted, .alreadyCompleted):
            true
        default:
            false
        }
    }
}

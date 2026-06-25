//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum SetupError: LocalizedError {
    case alreadySetup
    case noBackends

    var errorDescription: String? {
        switch self {
        case .alreadySetup:
            "Scout is already setup"
        case .noBackends:
            "Scout requires at least one backend"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .alreadySetup:
            "Review the code to ensure setup is called only once"
        case .noBackends:
            "Pass a .cloudKit or .server backend to setup"
        }
    }
}

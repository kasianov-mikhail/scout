//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum SetupError: LocalizedError {
    case noBackends

    var errorDescription: String? {
        switch self {
        case .noBackends:
            "Scout requires at least one backend"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noBackends:
            "Pass a .cloudKit or .server backend to setup"
        }
    }
}

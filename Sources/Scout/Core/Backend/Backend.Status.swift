//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Backend {
    enum Status: CaseIterable, Identifiable, Sendable {
        case reachable
        case unreachable
        case unknown

        var id: Self { self }

        var label: String {
            switch self {
            case .reachable: "Reachable"
            case .unreachable: "Unreachable"
            case .unknown: "Unknown"
            }
        }
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension Backend {
    package enum Status: Sendable, Equatable {
        case reachable
        case readOnly
        case unreachable
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum AlertState: Equatable, Codable {
    case armed
    case firing(since: Date)
    case muted(until: Date)
}

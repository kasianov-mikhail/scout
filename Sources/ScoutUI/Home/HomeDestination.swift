//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

enum HomeDestination: Hashable {
    case activity
    case retention
    case sessions
    case log
    case releaseHealth
    case alerts
}

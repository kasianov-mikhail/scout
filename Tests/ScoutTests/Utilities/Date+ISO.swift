//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Date {
    init(iso8601String: String) {
        self = ISO8601DateFormatter().date(from: iso8601String)!
    }
}

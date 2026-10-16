//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension DateFormatter {
    convenience init(format: String) {
        self.init()
        locale = Locale(identifier: "en_US_POSIX")
        calendar = .utc
        timeZone = Calendar.utc.timeZone
        dateFormat = format
    }
}

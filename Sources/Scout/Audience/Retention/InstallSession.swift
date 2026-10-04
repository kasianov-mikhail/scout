//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct InstallSession: Comparable {
    package let install: String
    package let date: Date
    package let os: String?

    package init(install: String, date: Date, os: String?) {
        self.install = install
        self.date = date
        self.os = os
    }

    package static func < (lhs: InstallSession, rhs: InstallSession) -> Bool {
        lhs.date < rhs.date
    }
}

extension [InstallSession] {
    var days: Set<Date> {
        Set(map(\.date.startOfDay))
    }

    var osMajor: String? {
        filter { $0.os != nil }.min()?.os.map { os in String(os.prefix { $0 != "." }) }
    }
}

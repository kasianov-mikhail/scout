//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct DatedID {
    package let date: Date
    package let id: String

    package init(date: Date, id: String) {
        self.date = date
        self.id = id
    }

    var startOfDay: DatedID {
        DatedID(date: date.startOfDay, id: id)
    }
}

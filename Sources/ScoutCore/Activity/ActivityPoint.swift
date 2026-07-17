//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A single day of active-user counts — the point a ``Database`` returns from
/// its activity query.
///
package struct ActivityPoint: Decodable, Sendable {
    package let date: Int64
    package let dau: Int
    package let wau: Int
    package let mau: Int

    package init(date: Int64, dau: Int, wau: Int, mau: Int) {
        self.date = date
        self.dau = dau
        self.wau = wau
        self.mau = mau
    }
}

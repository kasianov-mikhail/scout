//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum TestDate {
    // A fixed reference instant (2024-08-24 00:00:00 UTC) for tests that need a
    // stable, arbitrary date.
    static let reference = Date(timeIntervalSince1970: 1_724_457_600)
}

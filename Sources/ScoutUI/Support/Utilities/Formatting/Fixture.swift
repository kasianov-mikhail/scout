//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

protocol Fixture {
    static var samples: [Self] { get }
}

extension Array where Element: Fixture {
    static var samples: [Element] { Element.samples }
}

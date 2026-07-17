//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

protocol Ratio: ExpressibleByFloatLiteral {
    var value: Double { get }
    init(_ value: Double)
}

extension Ratio {
    init(floatLiteral value: Double) {
        self.init(value)
    }

    func percentage(fractionDigits: Int) -> String {
        String(format: "%.\(fractionDigits)f%%", value * 100)
    }
}

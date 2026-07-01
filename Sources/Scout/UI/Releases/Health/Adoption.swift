//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Adoption: ExpressibleByFloatLiteral {
    let value: Double

    init(_ value: Double) {
        self.value = value
    }

    init(floatLiteral value: Double) {
        self.value = value
    }

    var formatted: String {
        "\(Int((value * 100).rounded()))%"
    }
}

extension Adoption {
    init(of sessions: Int, in total: Int) {
        self.init(total > 0 ? Double(sessions) / Double(total) : 0)
    }
}

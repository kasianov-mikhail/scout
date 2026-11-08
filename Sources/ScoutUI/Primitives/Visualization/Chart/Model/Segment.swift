//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct Segment: Identifiable, Equatable {
    enum Kind: Equatable {
        case value(String)
        case other
    }

    let count: Int
    let color: Color
    let kind: Kind

    init(label: String, count: Int, color: Color) {
        self.init(count: count, color: color, kind: .value(label))
    }

    init(count: Int, color: Color, kind: Kind) {
        self.count = count
        self.color = color
        self.kind = kind
    }

    var label: String {
        switch kind {
        case .value(let label): label
        case .other: "Other"
        }
    }

    var id: String {
        switch kind {
        case .value(let label): "value:\(label)"
        case .other: "other"
        }
    }
}

extension [Segment] {
    var total: Int {
        reduce(0) { $0 + $1.count }
    }
}

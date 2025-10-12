//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol ChartPointProtocol {
    associatedtype Numeric: ChartNumeric

    var date: Date { get }
    var count: Numeric { get }

    init(date: Date, count: Numeric)
}

extension Collection where Element: ChartPointProtocol {
    var total: Element.Numeric {
        map(\.count).reduce(.zero, +)
    }
}

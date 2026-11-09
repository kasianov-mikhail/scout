//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

enum ChartGeometry {
    static let barRatio: Double = 0.7

    static var barStart: Double { barSlot.lowerBound }

    static var barEnd: Double { barSlot.upperBound }

    private static let barSlot: ClosedRange<Double> = (0.5 - barRatio / 2)...(0.5 + barRatio / 2)
}

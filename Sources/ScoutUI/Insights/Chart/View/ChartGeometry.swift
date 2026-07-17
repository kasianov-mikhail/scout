//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import ScoutCore

enum ChartGeometry {
    // Fraction of its slot a bar occupies.
    //
    // Pinned explicitly on both the plain bar marks and the comparison chart's
    // geometry, so the two modes render identical bars regardless of the
    // framework's default width.
    static let barRatio: Double = 0.7

    // Fraction across a bucket slot where the bar's leading edge sits.
    static var barStart: Double { barSlot.lowerBound }

    // Fraction across a bucket slot where the bar's trailing edge sits.
    static var barEnd: Double { barSlot.upperBound }

    // Horizontal portion of each bucket slot occupied by a bar, derived from
    // `barRatio` and applied through `barStart`/`barEnd`, so the marks and the
    // `ReferenceOverlay` place bar edges identically.
    private static let barSlot: ClosedRange<Double> = (0.5 - barRatio / 2)...(0.5 + barRatio / 2)
}

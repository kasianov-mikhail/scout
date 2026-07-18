//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

struct MetricsFormattersTests {
    @Test(
        "Formats sub-minute and coarse durations",
        arguments: [
            (0.0, "0"),
            (0.00045, "450 µs"),
            (0.123, "123 ms"),
            (12.34, "12.3 s"),
            (125.0, "2 min 5 s"),
            (7200.0, "2 h"),
            (172_800.0, "2 d"),
            (5_184_000.0, "2 mo"),
            (47_304_000.0, "1.5 y"),
        ]) func testDuration(seconds: TimeInterval, expected: String)
    {
        #expect(seconds.duration == expected)
    }

    @Test(
        "Rounds the seconds component into minutes instead of emitting 60 s",
        arguments: [
            (119.6, "2 min 0 s"),
            (119.5, "2 min 0 s"),
            (60.4, "1 min 0 s"),
            (89.5, "1 min 30 s"),
        ]) func testDurationSecondsCarry(seconds: TimeInterval, expected: String)
    {
        #expect(seconds.duration == expected)
    }

    @Test(
        "Promotes a value that rounds up to the next unit boundary",
        arguments: [
            (0.0009996, "1 ms"),
            (0.9996, "1.0 s"),
            (59.96, "1 min 0 s"),
            (3599.7, "1 h"),
            (86_399.0, "1 d"),
            (2_591_999.0, "1 mo"),
        ]) func testDurationUnitPromotion(seconds: TimeInterval, expected: String)
    {
        #expect(seconds.duration == expected)
    }
}

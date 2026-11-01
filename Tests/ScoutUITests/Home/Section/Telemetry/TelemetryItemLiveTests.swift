//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

struct TelemetryItemLiveTests {
    @Test("The log report maps to six rows")
    func report() {
        let report = LogSeries(snapshot: .sample(for: .today), period: .today, now: Date()).report
        let items = [TelemetryItem](report: report, resources: [ReleaseHealth].samples)

        #expect(items.map(\.kind.title) == ["Events", "Crashes", "Metrics", "Hangs", "Network", "Resources"])
        #expect(items.count == 6)
        #expect(items.allSatisfy { $0.value >= 0 })
        #expect(items.first?.caption.hasSuffix("yesterday") == true)
        #expect(items.last?.value == 2)
        #expect(items.last?.caption == "groups")
    }
}

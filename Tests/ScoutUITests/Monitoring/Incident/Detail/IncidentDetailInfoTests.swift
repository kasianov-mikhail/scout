//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

@Suite("Incident detail info")
struct IncidentDetailInfoTests {
    @Test("A crash names its report source")
    func crash() {
        let crash = Crash.stub(name: "Crash", date: Date(timeIntervalSince1970: 1_760_000_000))

        #expect(crash.detailMeta.source == "in-process report")
        #expect(crash.detailMeta.interval == nil)
        #expect(crash.detailMeta.dateText != nil)
    }

    @Test("A MetricKit crash uses its window")
    func metricKit() {
        let crash = Crash.sample(source: .metricKit(windowStart: Date(timeIntervalSince1970: 1_760_000_000)))

        #expect(crash.detailMeta.source == "MetricKit report")
        #expect(crash.detailMeta.interval != nil)
    }

    @Test("A hang adds its severity and duration")
    func hang() {
        let hang = Hang.stub(name: "Hang", duration: 9.2)

        #expect(hang.detailMeta.accent == "severe, 9.2 s")
        #expect(hang.detailMeta.source == nil)
    }

    @Test("A resource report names MetricKit")
    func resource() {
        let resource = ResourceException.sample

        #expect(resource.detailMeta.source == "MetricKit report")
        #expect(resource.detailCulprit == "Most CPU time in")
    }
}

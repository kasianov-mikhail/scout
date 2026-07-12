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

@Suite("GlanceSummary")
struct GlanceSummaryTests {
    @Test("All reachable backends read as operational")
    func allOperational() {
        let summary = GlanceSummary(backends: [
            makeHealth(id: "a", status: .reachable),
            makeHealth(id: "b", status: .reachable),
        ])

        #expect(summary.allOperational)
        #expect(summary.title == "All Systems Operational")
        #expect(summary.icon == "checkmark.seal.fill")
    }

    @Test("A degraded set reports the reachable count")
    func degraded() {
        let summary = GlanceSummary(backends: [
            makeHealth(id: "a", status: .reachable),
            makeHealth(id: "b", status: .unreachable),
            makeHealth(id: "c", status: .unknown),
        ])

        #expect(!summary.allOperational)
        #expect(summary.reachable == 1)
        #expect(summary.total == 3)
        #expect(summary.title == "1 of 3 Backends Reachable")
        #expect(summary.icon == "exclamationmark.triangle.fill")
    }

    @Test("Average latency is computed over backends that reported one")
    func averageLatency() {
        var fast = makeHealth(id: "fast", status: .reachable)
        fast = fast.recording(status: .reachable, latency: 100, at: Date())
        var slow = makeHealth(id: "slow", status: .reachable)
        slow = slow.recording(status: .reachable, latency: 300, at: Date())
        let silent = makeHealth(id: "silent")

        let summary = GlanceSummary(backends: [fast, slow, silent])

        #expect(summary.averageLatency == 200)
        #expect(summary.detail == "3 backends · 200 ms average latency")
    }

    @Test("Without latencies the detail only counts backends")
    func detailWithoutLatency() {
        let summary = GlanceSummary(backends: [makeHealth(id: "a")])

        #expect(summary.averageLatency == nil)
        #expect(summary.detail == "1 backend")
    }
}

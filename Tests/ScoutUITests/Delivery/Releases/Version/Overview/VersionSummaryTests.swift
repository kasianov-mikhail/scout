//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout
import Testing

@testable import ScoutUI

@Suite("VersionSummary")
struct VersionSummaryTests {
    private let now = Date().startOfDay
    private let shipped = Date().startOfDay.addingDay(-14)

    @Test("Header lines carry the health level, crash-free share and release age")
    func headerLines() {
        let summary = makeSummary()

        #expect(summary.statusLine == "Healthy · 99.82% crash-free")
        #expect(summary.adoptionLine == "62% of sessions · day 14")
        #expect(summary.shippedDate == DateFormatter.monthDay.string(from: shipped).uppercased())
    }

    @Test("Tiles read today's counts from the last trend day")
    func todayCounts() {
        let summary = makeSummary()

        #expect(summary.crashesToday == 1)
        #expect(summary.hangsToday == 1)
        #expect(summary.resourcesToday == 4)
        #expect(summary.freeUsersNote == "users 99.91%")
        #expect(summary.sessionsNote == "48.2K sessions")
        #expect(summary.resourcesNote == "4 today · CPU 7, disk 2")
    }

    @Test("Abnormal exits show the total share and the largest reason")
    func exits() {
        let summary = makeSummary()

        #expect(summary.exitsPerMille == "2.6 ‰")
        #expect(summary.topExitNote == "memory limit 1.3 ‰")
    }

    @Test("Performance tiles name the median and the previous version")
    func performance() {
        let summary = makeSummary()

        #expect(summary.launchValue == "466 ms")
        #expect(summary.launchNote == "median · ±0% vs 3.1.4")
        #expect(summary.hangRateText == "0.5 s/h · −32%")
        #expect((summary.hangRateChange ?? 0) < 0)
    }

    @Test("A signed percent keeps the sign and marks zero")
    func percent() {
        #expect(VersionSummary.percent(change: 0) == "±0%")
        #expect(VersionSummary.percent(change: 0.1) == "+10%")
        #expect(VersionSummary.percent(change: -0.316) == "−32%")
    }

    @Test("Launch bars show fourteen buckets around the data")
    func launchBars() {
        let summary = makeSummary()

        #expect(summary.launchBars.count == 14)
        #expect(summary.launchBars.max() == 120)
        #expect(summary.peakMemoryBars.count == 14)
    }

    private func makeSummary() -> VersionSummary {
        VersionSummary(release: makeRelease(), trend: .sample, now: now)
    }

    private func makeRelease() -> ReleaseHealth {
        ReleaseHealth(
            id: "3.2.0",
            shippedAt: shipped,
            freeSessions: 0.9982,
            freeUsers: Stability(0.9991),
            crashes: 14,
            hangs: 9,
            sessions: 48_210,
            adoption: 0.62,
            exits: ExitSummary(counts: [
                .normal: 41_200,
                .memoryPressure: 6_100,
                .memoryLimit: 64,
                .watchdog: 38,
                .badAccess: 14,
                .abnormal: 9,
            ]),
            performance: .sample,
            resources: .sample
        )
    }
}

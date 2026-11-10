//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

struct ReleaseDetailTests {
    private let release = [ReleaseHealth].samples[0]
    private var detail: ReleaseDetail {
        ReleaseDetail(release: release, trend: .sample, now: (release.shipped ?? Date()).addingDay(14))
    }

    private func tile(_ kind: ReleaseTileValue.Kind) throws -> ReleaseTileValue {
        try #require(detail.tiles.first { $0.kind == kind })
    }

    @Test("The hero reads the status, adoption and age")
    func hero() {
        #expect(detail.statusLabel == "Healthy · 99.82% crash-free")
        #expect(detail.subtitle == "62% of sessions · day 14")
    }

    @Test("The grid holds the eight release metrics in order")
    func order() {
        #expect(detail.tiles.map(\.kind) == [.crashFree, .adoption, .crashes, .hangs, .resources, .exits, .launchTime, .peakMemory])
        #expect(
            detail.tiles.map(\.kind.title) == [
                "Crash-free sessions", "Adoption", "Crashes", "Hangs", "Resources", "Abnormal exits", "Launch time", "Peak memory",
            ])
    }

    @Test("Crash-free reads the session rate and the user rate")
    func crashFree() throws {
        let tile = try tile(.crashFree)

        #expect(tile.value == "99.82%")
        #expect(tile.footer == "users 99.91%")

        guard case .zones(let value) = tile.chart else {
            return
        }
        #expect(value == 0.9982)
    }

    @Test("Adoption reads the share and the session count")
    func adoption() throws {
        let tile = try tile(.adoption)

        #expect(tile.value == "62%")
        #expect(tile.footer == "48.2K sessions")

        guard case .progress(let value) = tile.chart else {
            return
        }
        #expect(value == 0.62)
    }

    @Test("Crashes and hangs read the two-week bars and today")
    func incidents() throws {
        let crashes = try tile(.crashes)
        let hangs = try tile(.hangs)

        #expect(crashes.value == "14")
        #expect(crashes.footer == "1 today")
        #expect(hangs.value == "9")
        #expect(hangs.footer == "1 today")

        guard case .bars(let values, _) = crashes.chart, case .bars(let hangValues, _) = hangs.chart else {
            return
        }
        #expect(values.count == 14)
        #expect(values.last == 1)
        #expect(hangValues.count == 14)
        #expect(hangValues.last == 1)
    }

    @Test("Resources read the kinds and today")
    func resources() throws {
        let tile = try tile(.resources)

        #expect(tile.value == "9")
        #expect(tile.footer == "4 today · CPU 7, disk 2")
    }

    @Test("Abnormal exits read per mille and the leading reason")
    func exits() throws {
        let tile = try tile(.exits)

        #expect(tile.value == "2.6 ‰")
        #expect(tile.footer == "memory limit 1.3 ‰")

        guard case .segments(let values) = tile.chart else {
            return
        }
        #expect(values.count == 4)
    }

    @Test("Performance reads the medians and compares with the previous version")
    func performance() throws {
        let launch = try tile(.launchTime)
        let memory = try tile(.peakMemory)

        #expect(launch.value == String(format: "%.0f ms", release.performance.current.launchTime ?? 0))
        #expect(launch.footer == "median · ±0% vs 3.1.4")
        #expect(memory.value == String(format: "%.0f MB", release.performance.current.peakMemory ?? 0))
        #expect(memory.footer == "median · ±0% vs 3.1.4")
    }

    @Test("The hang rate compares with the previous version")
    func hangRate() {
        #expect(detail.hangRate.value == "0.5 s/h")
        #expect(detail.hangRate.change == "−32%")
    }
}

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
@testable import Support

@MainActor
struct ResetMarkerProviderTests {
    private let first = Date(year: 2026, month: 6, day: 10, hour: 9)
    private let second = Date(year: 2026, month: 6, day: 10, hour: 14)
    private let foreign = Date(year: 2026, month: 6, day: 10, hour: 11)

    private func markers() -> ServerStub {
        ServerStub(metrics: [
            MetricSeries(
                name: "api_calls",
                category: ResetMarker.category,
                points: [
                    MetricSeriesPoint(date: first.millisecondsSince1970, value: .int(1)),
                    MetricSeriesPoint(date: second.millisecondsSince1970, value: .int(1)),
                ]
            ),
            MetricSeries(
                name: "errors",
                category: ResetMarker.category,
                points: [MetricSeriesPoint(date: foreign.millisecondsSince1970, value: .int(1))]
            ),
        ])
    }

    @Test("Markers resolve to the reset dates of the named counter only")
    func fetchKeepsTheNamedCounter() async throws {
        let provider = ResetMarkerProvider(name: "api_calls", isEnabled: true)
        await provider.fetchIfNeeded(in: markers())

        #expect(try provider.result?.get() == [first, second])
    }

    @Test("A disabled provider resolves to no markers")
    func disabledProviderStaysEmpty() async throws {
        let provider = ResetMarkerProvider(name: "api_calls", isEnabled: false)
        await provider.fetchIfNeeded(in: markers())

        #expect(try provider.result?.get() == [])
    }

    @Test("dates(in:) keeps only the markers inside the range")
    func datesAreClippedToTheRange() async {
        let provider = ResetMarkerProvider(name: "api_calls", isEnabled: true)
        await provider.fetchIfNeeded(in: markers())

        let from = Date(year: 2026, month: 6, day: 10, hour: 10)

        #expect(provider.dates(in: from..<second.addingTimeInterval(1)) == [second])
    }

    @Test("dates(in:) is empty before the markers load")
    func datesAreEmptyWithoutAResult() {
        let provider = ResetMarkerProvider(name: "api_calls", isEnabled: true)

        #expect(provider.dates(in: first..<second).isEmpty)
    }

    @Test("Only counters carry resets")
    func onlyCountersHaveResets() {
        #expect(Telemetry.Export.counter.hasResets)
        #expect(Telemetry.Export.floatingCounter.hasResets)
        #expect(!Telemetry.Export.timer.hasResets)
        #expect(!Telemetry.Export.recorder.hasResets)
        #expect(!Telemetry.Export.meter.hasResets)
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

@Suite("MetricKitPerformance")
struct MetricKitPerformanceTests {
    @Test("Launch buckets fold into 100 ms cells by their midpoint")
    func launchesFoldIntoGrid() {
        let performance = makePerformance(launches: [
            .init(start: 150, end: 160, count: 3),
            .init(start: 180, end: 190, count: 2),
            .init(start: 190, end: 210, count: 4),
            .init(start: 1_000, end: 1_100, count: 1),
            .init(start: 300, end: 310, count: 0),
        ])

        #expect(
            performance.readings == [
                DailyMetricReading(name: "launch_time", category: "100", value: 5),
                DailyMetricReading(name: "launch_time", category: "200", value: 4),
                DailyMetricReading(name: "launch_time", category: "1000", value: 1),
            ]
        )
    }

    @Test("Hang buckets add up to a total hang time in milliseconds")
    func hangsAddUpToTotal() {
        let performance = makePerformance(hangs: [
            .init(start: 250, end: 350, count: 2),
            .init(start: 1_000, end: 2_000, count: 1),
        ])

        #expect(performance.readings == [DailyMetricReading(name: "hang_time", category: nil, value: 2_100)])
    }

    @Test("Foreground time is a total in seconds")
    func foregroundTimeIsTotal() {
        let performance = makePerformance(foregroundSeconds: 3_600.4)

        #expect(performance.readings == [DailyMetricReading(name: "foreground_time", category: nil, value: 3_600)])
    }

    @Test("Peak memory counts one device in its 50 MB cell")
    func peakMemoryFallsIntoCell() {
        let performance = makePerformance(peakMemoryMegabytes: 187.5)

        #expect(performance.readings == [DailyMetricReading(name: "peak_memory", category: "150", value: 1)])
    }

    @Test("An empty payload has no readings")
    func emptyPayloadHasNoReadings() {
        #expect(makePerformance().readings.isEmpty)
    }

    private func makePerformance(launches: [MetricKitPerformance.Bucket] = [], hangs: [MetricKitPerformance.Bucket] = [], foregroundSeconds: Double = 0, peakMemoryMegabytes: Double? = nil) -> MetricKitPerformance {
        MetricKitPerformance(launches: launches, hangs: hangs, foregroundSeconds: foregroundSeconds, peakMemoryMegabytes: peakMemoryMegabytes)
    }
}

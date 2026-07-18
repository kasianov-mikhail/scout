//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("MetricSeries lifecycle")
struct MetricSeriesLifecycleTests {
    @Test("Every reserved lifecycle record name is flagged as lifecycle")
    func reservedNamesAreLifecycle() {
        let reserved = [
            DeviceEntry.recordType,
            InstallEntry.recordType,
            LaunchEntry.recordType,
            SessionEntry.recordType,
            VersionEntry.recordType,
            MarkerEntry.crashName,
        ]

        #expect(MetricSeries.lifecycleNames == Set(reserved))

        for name in reserved {
            #expect(makeSeries(name: name).isLifecycle)
        }
    }

    @Test("Diagnostics and custom events are not lifecycle")
    func othersAreNotLifecycle() {
        #expect(!makeSeries(name: CrashEntry.recordType).isLifecycle)
        #expect(!makeSeries(name: HangEntry.recordType).isLifecycle)
        #expect(!makeSeries(name: EventEntry.recordType).isLifecycle)
        #expect(!makeSeries(name: "login").isLifecycle)
    }

    private func makeSeries(name: String) -> MetricSeries {
        MetricSeries(name: name, category: nil, points: [])
    }
}

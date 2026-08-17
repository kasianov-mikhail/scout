//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import DemoConnector
@testable import Scout
@testable import ScoutUI

@MainActor
@Suite struct DemoScreensTests {
    let database = DemoDatabase(corpus: DemoDatabaseTests.corpus)

    @Test func releaseHealthLightsUp() async throws {
        let health = try await ReleaseHealthProvider().fetch(in: database)
        #expect(health.count > 0)
    }

    @Test func releaseHealthReadsHealthy() async throws {
        let health = try await ReleaseHealthProvider().fetch(in: database)

        for release in health {
            #expect(release.freeSessions.value >= 0.99, "\(release.id) crash-free sessions reads as a disaster")
            #expect(release.freeUsers?.value ?? 1 >= 0.98, "\(release.id) crash-free users reads red")
            #expect(release.sessions > 0)
        }
    }

    @Test func devicesLightUp() async throws {
        let report = try await DevicesProvider().fetch(in: database)
        #expect(report.summaries.count > 0)
    }

    @Test func networkLightsUp() async throws {
        let report = try await NetworkProvider().fetch(in: database)
        #expect(!report.isEmpty)
    }

    @Test func timerDistributionLightsUp() async throws {
        let distribution = try await MetricDistributionProvider<LatencyHistogram>(
            name: DemoMetrics.timers[0], categories: LatencyBuckets.categories
        ).fetch(in: database)
        #expect(!distribution.isEmpty)
    }

    @Test func activityLightsUp() async throws {
        let points = try await ActivityProvider().fetch(in: database)
        #expect(points.count > 0)
    }

    @Test func retentionLightsUp() async throws {
        let cohorts = try await RetentionProvider().fetch(in: database)
        #expect(cohorts.count > 0)
    }

    @Test func homeSessionStatLightsUp() async throws {
        let points = try await StatProvider(eventName: SessionEntry.recordType).fetch(in: database)
        #expect(points.count > 0)
    }

    @Test func eventStatLightsUp() async throws {
        let points = try await StatProvider(eventName: "Search_Performed").fetch(in: database)
        #expect(points.count > 0)
    }

    @Test func homeLogLightsUp() async throws {
        let series = try await HomeLogProvider().fetch(in: database)
        #expect(series.count > 0)
    }

    @Test func deviceTimelineLightsUp() async throws {
        let records = try await database.read(
            matching: RecordQuery(recordType: Device.self), fields: nil, limit: 1
        ).records
        let stored: String? = records.first?["device_id"]
        let deviceID = try #require(stored.flatMap(UUID.init))

        let provider = TimelineProvider()
        await provider.start(
            feed: TimelineFeed(deviceID: deviceID, database: database), anchorEvent: nil, eventName: nil)

        let rail = try #require(try provider.result?.get())
        #expect(rail.installs.count > 0)
        #expect(provider.items.count > 0, "device timeline renders no rows")
    }
}

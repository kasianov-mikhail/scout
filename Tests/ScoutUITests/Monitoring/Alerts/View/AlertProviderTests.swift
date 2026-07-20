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
@testable import Support

@MainActor
struct AlertProviderTests {
    private let defaults = UserDefaults(suiteName: "AlertProviderTests-\(UUID().uuidString)")!

    @Test("An error spike over the baseline fires once and stays firing on the next refresh")
    func firesOnce() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "Error", counts: errorCounts))

        let provider = makeProvider(rules: [errorRule])

        let first = try await provider.fetch(in: database)

        #expect(first.count == 1)
        #expect(first[0].outcome.shouldNotify)

        let second = try await provider.fetch(in: database)

        #expect(!second[0].outcome.shouldNotify)
        #expect(second[0].outcome.state == first[0].outcome.state)
    }

    @Test("A crash-free dip below the threshold fires")
    func crashFree() async throws {
        let database = DatabaseStub()
        database.add(
            series: makeSeries(
                name: SessionEntry.recordType, counts: [(hoursAgo: 1, count: 10), (hoursAgo: 2, count: 10)]),
            makeSeries(name: CrashEntry.recordType, counts: [(hoursAgo: 1, count: 1), (hoursAgo: 2, count: 1)])
        )

        let provider = makeProvider(rules: [crashFreeRule])
        let statuses = try await provider.fetch(in: database)

        #expect(statuses[0].outcome.shouldNotify)
    }

    @Test("A firing refresh posts one notification and the next refresh stays silent")
    func deliversOnce() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "Error", counts: errorCounts))

        let center = NotificationCenterStub()
        let provider = makeProvider(rules: [errorRule], center: center)

        _ = try await provider.fetch(in: database)

        #expect(center.requests.count == 1)
        #expect(center.requests.first?.content.title == "Error")

        _ = try await provider.fetch(in: database)

        #expect(center.requests.count == 1)
    }

    @Test("A firing state survives into a new provider instance")
    func statePersists() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "Error", counts: errorCounts))

        let center = NotificationCenterStub()

        _ = try await makeProvider(rules: [errorRule], center: center).fetch(in: database)
        _ = try await makeProvider(rules: [errorRule], center: center).fetch(in: database)

        #expect(center.requests.count == 1)
    }

    @Test("A healthy metric stays armed")
    func healthy() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: SessionEntry.recordType, counts: [(hoursAgo: 1, count: 10)]))

        let provider = makeProvider(rules: [crashFreeRule])
        let statuses = try await provider.fetch(in: database)

        #expect(statuses[0].outcome == AlertOutcome(state: .armed, shouldNotify: false))
    }

    @Test("Adding the first rule requests notification authorization once")
    func firstRuleAuthorization() async {
        let center = NotificationCenterStub()
        let provider = makeProvider(rules: [], center: center)

        await provider.add(errorRule)

        #expect(center.authorizationRequests == 1)
        #expect(provider.rules == [errorRule])

        await provider.add(crashFreeRule)

        #expect(center.authorizationRequests == 1)
        #expect(provider.rules.count == 2)
    }

    @Test("Removing a rule leaves the others in place")
    func remove() async {
        let provider = makeProvider(rules: [errorRule, crashFreeRule])

        provider.remove(errorRule)

        #expect(provider.rules == [crashFreeRule])
    }

    private var errorRule: AlertRule {
        AlertRule(
            metric: .eventCount(name: "Error"),
            condition: AlertCondition(comparison: .above, reference: .baselineFactor(2))
        )
    }

    private var crashFreeRule: AlertRule {
        AlertRule(
            metric: .crashFreeSessions,
            condition: AlertCondition(comparison: .below, reference: .constant(0.995)),
            holdBuckets: 2
        )
    }

    private var errorCounts: [(hoursAgo: Int, count: Int)] {
        (25...48).map { (hoursAgo: $0, count: 4) } + [(hoursAgo: 1, count: 20)]
    }

    private func makeProvider(rules: [AlertRule], center: NotificationCenterStub? = nil) -> AlertProvider {
        let store = AlertStore(defaults: defaults)
        store.rules = rules
        return AlertProvider(store: store, notifier: center.map { AlertNotifier(center: $0) })
    }

    private func makeSeries(name: String, counts: [(hoursAgo: Int, count: Int)]) -> MetricSeries {
        let horizon = Date().startOfHour

        return MetricSeries(
            name: name,
            category: nil,
            points: counts.map {
                MetricSeriesPoint(
                    date: horizon.addingHour(-$0.hoursAgo).millisecondsSince1970,
                    value: .int($0.count)
                )
            }
        )
    }
}

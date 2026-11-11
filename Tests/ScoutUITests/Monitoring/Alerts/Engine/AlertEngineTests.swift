//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing
import UserNotifications

@testable import ScoutUI
@testable import Support

@MainActor
struct AlertEngineTests {
    private let defaults = UserDefaults(suiteName: "AlertEngineTests-\(UUID().uuidString)")!

    @Test("An error spike over the baseline fires once and stays firing on the next run")
    func firesOnce() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "Error", counts: errorCounts))

        let engine = try makeEngine(rules: [errorRule])

        let first = try await engine.run(in: database)

        #expect(first.count == 1)
        #expect(first[0].outcome.shouldNotify)

        let second = try await engine.run(in: database)

        #expect(!second[0].outcome.shouldNotify)
        #expect(second[0].outcome.state == first[0].outcome.state)
    }

    @Test("An error spike after a quiet previous day fires")
    func firesOverQuietBaseline() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "Error", counts: [(hoursAgo: 1, count: 50)]))

        let statuses = try await makeEngine(rules: [errorRule]).run(in: database)

        #expect(statuses[0].reading.baseline == 0)
        #expect(statuses[0].outcome.shouldNotify)
    }

    @Test("A crash-free dip below the threshold fires")
    func crashFree() async throws {
        let database = DatabaseStub()
        database.add(
            series: makeSeries(
                name: Session.recordType, counts: [(hoursAgo: 1, count: 10), (hoursAgo: 2, count: 10)]),
            makeSeries(name: Crash.recordType, counts: [(hoursAgo: 1, count: 1), (hoursAgo: 2, count: 1)])
        )

        let engine = try makeEngine(rules: [crashFreeRule])
        let statuses = try await engine.run(in: database)

        #expect(statuses[0].outcome.shouldNotify)
    }

    @Test("A firing run posts one notification and the next run stays silent")
    func deliversOnce() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "Error", counts: errorCounts))

        let center = NotificationCenterStub()
        let engine = try makeEngine(rules: [errorRule], center: center)

        _ = try await engine.run(in: database)

        #expect(center.requests.count == 1)
        #expect(center.requests.first?.content.title == "Error")

        _ = try await engine.run(in: database)

        #expect(center.requests.count == 1)
    }

    @Test("A refused notification is retried on the next run")
    func refusedNotificationRetries() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "Error", counts: errorCounts))

        let center = NotificationCenterStub()
        center.addError = NSError(domain: UNErrorDomain, code: 1)
        let engine = try makeEngine(rules: [errorRule], center: center)

        _ = try await engine.run(in: database)

        #expect(center.requests.isEmpty)

        center.addError = nil
        let second = try await engine.run(in: database)

        #expect(second[0].outcome.shouldNotify)
        #expect(center.requests.count == 1)
    }

    @Test("A firing state survives into a new engine instance")
    func statePersists() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "Error", counts: errorCounts))

        let center = NotificationCenterStub()

        _ = try await makeEngine(rules: [errorRule], center: center).run(in: database)
        _ = try await makeEngine(rules: [errorRule], center: center).run(in: database)

        #expect(center.requests.count == 1)
    }

    @Test("A read infers a firing start without recording it")
    func readInfersStart() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "Error", counts: errorCounts))

        let registry = AlertRegistry(defaults: defaults)
        try registry.save([errorRule])
        let engine = AlertEngine(registry: registry, notifier: nil)

        let first = try await engine.statuses(in: database)
        let second = try await engine.statuses(in: database)

        #expect(!first[0].outcome.isRecorded)
        #expect(!second[0].outcome.isRecorded)
        #expect(first[0].firingLabel() == "Firing")
        #expect(second[0].firingLabel() == "Firing")
        #expect(first[0].notified == nil)
        #expect(try registry.state(for: errorRule) == .armed)
    }

    @Test("A run records the firing start and the delivery time")
    func runRecordsStart() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "Error", counts: errorCounts))

        let registry = AlertRegistry(defaults: defaults)
        try registry.save([errorRule])
        let engine = AlertEngine(registry: registry, notifier: AlertNotifier(center: NotificationCenterStub()))

        _ = try await engine.run(in: database)
        let statuses = try await engine.statuses(in: database)

        #expect(statuses[0].outcome.isRecorded)
        #expect(statuses[0].firingLabel() == "Firing 1 h")
        #expect(statuses[0].notified != nil)
        #expect(try registry.notified(for: errorRule) != nil)
    }

    @Test("A rule that does not notify records no delivery time")
    func silentRule() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "Error", counts: errorCounts))

        let registry = AlertRegistry(defaults: defaults)
        let rule = AlertRule(
            metric: .eventCount(name: "Error"),
            condition: AlertCondition(comparison: .above, reference: .baselineFactor(2)),
            notifies: false
        )
        try registry.save([rule])
        let center = NotificationCenterStub()
        let engine = AlertEngine(registry: registry, notifier: AlertNotifier(center: center))

        let statuses = try await engine.run(in: database)

        #expect(statuses[0].outcome.shouldNotify)
        #expect(center.requests.isEmpty)
        #expect(try registry.notified(for: rule) == nil)
    }

    @Test("A refused notification records no delivery time")
    func refusedNotificationRecordsNothing() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "Error", counts: errorCounts))

        let registry = AlertRegistry(defaults: defaults)
        try registry.save([errorRule])
        let center = NotificationCenterStub()
        center.addError = NSError(domain: UNErrorDomain, code: 1)
        let engine = AlertEngine(registry: registry, notifier: AlertNotifier(center: center))

        _ = try await engine.run(in: database)

        #expect(try registry.notified(for: errorRule) == nil)
    }

    @Test("A recovered rule forgets its delivery time")
    func recoveryForgetsNotified() async throws {
        let registry = AlertRegistry(defaults: defaults)
        try registry.save([errorRule])
        let engine = AlertEngine(registry: registry, notifier: AlertNotifier(center: NotificationCenterStub()))

        let firing = DatabaseStub()
        firing.add(series: makeSeries(name: "Error", counts: errorCounts))
        _ = try await engine.run(in: firing)

        #expect(try registry.notified(for: errorRule) != nil)

        let healthy = DatabaseStub()
        healthy.add(series: makeSeries(name: "Error", counts: (25...48).map { (hoursAgo: $0, count: 4) }))
        _ = try await engine.run(in: healthy)

        #expect(try registry.notified(for: errorRule) == nil)
    }

    @Test("A healthy metric stays armed")
    func healthy() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: Session.recordType, counts: [(hoursAgo: 1, count: 10)]))

        let engine = try makeEngine(rules: [crashFreeRule])
        let statuses = try await engine.run(in: database)

        #expect(statuses[0].outcome == AlertOutcome(state: .armed, shouldNotify: false))
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

    private func makeEngine(rules: [AlertRule], center: NotificationCenterStub? = nil) throws -> AlertEngine {
        let registry = AlertRegistry(defaults: defaults)
        try registry.save(rules)
        return AlertEngine(registry: registry, notifier: center.map { AlertNotifier(center: $0) })
    }

    private func makeSeries(name: String, counts: [(hoursAgo: Int, count: Int)]) -> MetricSeries {
        let horizon = Date().startOfHour

        return MetricSeries(
            name: name,
            category: nil,
            points: counts.map {
                MetricSeriesPoint(
                    date: horizon.addingHour(-$0.hoursAgo),
                    value: Double($0.count)
                )
            }
        )
    }
}

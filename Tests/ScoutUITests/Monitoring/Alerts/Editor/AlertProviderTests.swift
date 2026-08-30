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

    @Test("Fetching reads statuses for display without advancing state or delivering")
    func fetchIsReadOnly() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "Error", counts: errorCounts))

        let center = NotificationCenterStub()
        let registry = AlertRegistry(defaults: defaults)
        try registry.save([errorRule])
        let provider = AlertProvider(registry: registry, notifier: AlertNotifier(center: center))

        let statuses = try await provider.fetch(in: database)

        #expect(statuses[0].outcome.shouldNotify)
        #expect(center.requests.count == 0)
        #expect(try registry.state(for: errorRule) == .armed)
    }

    @Test("Adding the first rule requests notification authorization once")
    func firstRuleAuthorization() async throws {
        let center = NotificationCenterStub()
        center.status = .notDetermined
        let registry = AlertRegistry(defaults: defaults)
        let provider = AlertProvider(registry: registry, notifier: AlertNotifier(center: center))

        await provider.add(errorRule)

        #expect(center.authorizationRequests == 1)
        #expect(try registry.rules() == [errorRule])

        await provider.add(crashFreeRule)

        #expect(center.authorizationRequests == 1)
        #expect(try registry.rules().count == 2)
    }

    @Test("A refused prompt makes the provider report that notifications are denied")
    func refusedPrompt() async {
        let center = NotificationCenterStub()
        center.status = .notDetermined
        center.grant = false
        let provider = AlertProvider(registry: AlertRegistry(defaults: defaults), notifier: AlertNotifier(center: center))

        await provider.add(errorRule)

        #expect(provider.notificationsDenied)
    }

    @Test("A rule added while authorization is still undetermined asks again")
    func undeterminedAuthorization() async throws {
        let center = NotificationCenterStub()
        center.status = .notDetermined
        let registry = AlertRegistry(defaults: defaults)
        try registry.save([errorRule])
        let provider = AlertProvider(registry: registry, notifier: AlertNotifier(center: center))

        await provider.add(crashFreeRule)

        #expect(center.authorizationRequests == 1)
    }

    @Test("Removing a rule leaves the others in place")
    func remove() async throws {
        let registry = AlertRegistry(defaults: defaults)
        try registry.save([errorRule, crashFreeRule])
        let provider = AlertProvider(registry: registry)

        provider.remove(errorRule)

        #expect(try registry.rules() == [crashFreeRule])
    }

    @Test("A denied center makes the provider report that notifications are denied")
    func notificationsDeniedWhenDenied() async {
        let center = NotificationCenterStub()
        center.status = .denied
        let provider = AlertProvider(registry: AlertRegistry(defaults: defaults), notifier: AlertNotifier(center: center))

        await provider.refreshNotificationStatus()

        #expect(provider.notificationsDenied)

        center.status = .authorized
        await provider.refreshNotificationStatus()

        #expect(!provider.notificationsDenied)
    }

    @Test("A center that has not been asked yet doesn't claim notifications are denied")
    func notificationsNotDeniedWhenNotDetermined() async {
        let center = NotificationCenterStub()
        center.status = .notDetermined
        let provider = AlertProvider(registry: AlertRegistry(defaults: defaults), notifier: AlertNotifier(center: center))

        await provider.refreshNotificationStatus()

        #expect(!provider.notificationsDenied)
    }

    @Test("Adding a rule over an unreadable store fails instead of overwriting it")
    func addOverUnreadableStore() async {
        let blob = Data("garbage".utf8)
        defaults.set(blob, forKey: "scout_alert_rules")
        let provider = AlertProvider(registry: AlertRegistry(defaults: defaults))

        await provider.add(errorRule)

        #expect(provider.error is AlertRegistry.UnreadableStoreError)
        #expect(defaults.data(forKey: "scout_alert_rules") == blob)
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

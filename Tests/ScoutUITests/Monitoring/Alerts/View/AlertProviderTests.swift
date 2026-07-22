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
        registry.rules = [errorRule]
        let provider = AlertProvider(registry: registry, notifier: AlertNotifier(center: center))

        let statuses = try await provider.fetch(in: database)

        #expect(statuses[0].outcome.shouldNotify)
        #expect(center.requests.count == 0)
        #expect(registry.state(for: errorRule) == .armed)
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
        let registry = AlertRegistry(defaults: defaults)
        registry.rules = rules
        return AlertProvider(registry: registry, notifier: center.map { AlertNotifier(center: $0) })
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

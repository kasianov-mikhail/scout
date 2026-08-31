//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing
import UserNotifications

@testable import ScoutUI

// `ephemeral` is an App Clip status that UserNotifications marks unavailable on
// macOS, and the contract job builds this target for macOS.
private let authorizationStatuses: [(UNAuthorizationStatus, Bool)] = {
    var statuses: [(UNAuthorizationStatus, Bool)] = [
        (.denied, true),
        (.authorized, false),
        (.provisional, false),
        (.notDetermined, false),
    ]
    #if !os(macOS)
        statuses.append((.ephemeral, false))
    #endif
    return statuses
}()

struct AlertNotifierTests {
    @Test("Only notifying statuses become notifications")
    func delivers() async throws {
        let center = NotificationCenterStub()
        let notifier = AlertNotifier(center: center)

        await notifier.deliver([
            makeStatus(shouldNotify: true),
            makeStatus(shouldNotify: false),
        ])

        let request = try #require(center.requests.first)

        #expect(center.requests.count == 1)
        #expect(request.content.title == "Crash-free sessions")
        #expect(request.content.body == "90.00% — below 99.50%")
        #expect(request.trigger == nil)
    }

    @Test("A refused notification is reported as undelivered")
    func refusedDelivery() async {
        let center = NotificationCenterStub()
        center.addError = NSError(domain: UNErrorDomain, code: 1)

        let notifier = AlertNotifier(center: center)
        let status = makeStatus(shouldNotify: true)
        let undelivered = await notifier.deliver([status])

        #expect(undelivered.map(\.rule) == [status.rule])
        #expect(center.requests.count == 0)
    }

    @Test("A delivered notification leaves nothing undelivered")
    func acceptedDelivery() async {
        let center = NotificationCenterStub()
        let notifier = AlertNotifier(center: center)

        let undelivered = await notifier.deliver([makeStatus(shouldNotify: true)])

        #expect(undelivered.count == 0)
        #expect(center.requests.count == 1)
    }

    @Test("Only a denied center refuses notifications", arguments: authorizationStatuses)
    func refusesNotifications(status: UNAuthorizationStatus, refuses: Bool) async {
        let center = NotificationCenterStub()
        center.status = status

        #expect(await AlertNotifier(center: center).refusesNotifications() == refuses)
    }

    @Test("Requesting authorization asks the center once")
    func authorization() async {
        let center = NotificationCenterStub()

        await AlertNotifier(center: center).requestAuthorization()

        #expect(center.authorizationRequests == 1)
    }

    private func makeStatus(shouldNotify: Bool) -> AlertStatus {
        AlertStatus(
            rule: AlertRule(
                metric: .crashFreeSessions,
                condition: AlertCondition(comparison: .below, reference: .constant(0.995))
            ),
            outcome: AlertOutcome(state: .firing(since: Date(timeIntervalSince1970: 0)), shouldNotify: shouldNotify),
            reading: MetricReading(baseline: 0, recent: [0.9])
        )
    }
}

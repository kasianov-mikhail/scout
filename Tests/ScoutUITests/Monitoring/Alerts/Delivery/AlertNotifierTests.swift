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

        #expect(undelivered == [status.rule])
        #expect(center.requests.count == 0)
    }

    @Test("A delivered notification leaves nothing undelivered")
    func acceptedDelivery() async {
        let center = NotificationCenterStub()
        let notifier = AlertNotifier(center: center)

        let undelivered = await notifier.deliver([makeStatus(shouldNotify: true)])

        #expect(undelivered.isEmpty)
        #expect(center.requests.count == 1)
    }

    @Test(
        "Only a denied center refuses notifications",
        arguments: [
            (UNAuthorizationStatus.denied, true),
            (.authorized, false),
            (.provisional, false),
            (.ephemeral, false),
            (.notDetermined, false),
        ])
    func refusesNotifications(status: UNAuthorizationStatus, refuses: Bool) async {
        let center = NotificationCenterStub()
        center.status = status

        #expect(await AlertNotifier(center: center).refusesNotifications() == refuses)
    }

    @Test("Authorization passes the center's grant through")
    func authorization() async {
        let center = NotificationCenterStub()
        center.granted = false

        let notifier = AlertNotifier(center: center)
        let granted = await notifier.requestAuthorization()

        #expect(!granted)
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

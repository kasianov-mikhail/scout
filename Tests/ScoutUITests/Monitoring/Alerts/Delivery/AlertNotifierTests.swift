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
        let notifying = makeStatus(shouldNotify: true)

        let delivery = await notifier.deliver([
            notifying,
            makeStatus(shouldNotify: false),
        ])

        let request = try #require(center.requests.first)

        #expect(center.requests.count == 1)
        #expect(request.content.title == "Crash-free sessions")
        #expect(request.content.body == "90.00% — below 99.50%")
        #expect(request.trigger == nil)
        #expect(delivery.delivered.map(\.rule) == [notifying.rule])
        #expect(delivery.undelivered.isEmpty)
    }

    @Test("A refused notification is reported as undelivered")
    func refusedDelivery() async {
        let center = NotificationCenterStub()
        center.addError = NSError(domain: UNErrorDomain, code: 1)

        let notifier = AlertNotifier(center: center)
        let status = makeStatus(shouldNotify: true)
        let delivery = await notifier.deliver([status])

        #expect(delivery.undelivered.map(\.rule) == [status.rule])
        #expect(delivery.delivered.isEmpty)
        #expect(center.requests.isEmpty)
    }

    @Test("A delivered notification leaves nothing undelivered")
    func acceptedDelivery() async {
        let center = NotificationCenterStub()
        let notifier = AlertNotifier(center: center)
        let status = makeStatus(shouldNotify: true)

        let delivery = await notifier.deliver([status])

        #expect(delivery.delivered.map(\.rule) == [status.rule])
        #expect(delivery.undelivered.isEmpty)
        #expect(center.requests.count == 1)
    }

    @Test("A rule that does not notify delivers nothing")
    func silentRule() async {
        let center = NotificationCenterStub()
        let notifier = AlertNotifier(center: center)

        let delivery = await notifier.deliver([makeStatus(shouldNotify: true, notifies: false)])

        #expect(delivery.delivered.isEmpty)
        #expect(delivery.undelivered.isEmpty)
        #expect(center.requests.isEmpty)
    }

    private func makeStatus(shouldNotify: Bool, notifies: Bool = true) -> AlertStatus {
        AlertStatus(
            rule: AlertRule(
                metric: .crashFreeSessions,
                condition: AlertCondition(comparison: .below, reference: .constant(0.995)),
                notifies: notifies
            ),
            outcome: AlertOutcome(state: .firing(since: Date(timeIntervalSince1970: 0)), shouldNotify: shouldNotify),
            reading: MetricReading(baseline: 0, recent: [0.9])
        )
    }
}

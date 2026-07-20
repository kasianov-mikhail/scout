//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

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

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI
@testable import Support

struct AlertEvaluatorTests {
    private let evaluator = AlertEvaluator()
    private let now = Date(year: 2026, month: 7, day: 20, hour: 14)

    private let rule = AlertRule(
        metric: .crashFreeSessions,
        condition: AlertCondition(comparison: .below, reference: .constant(0.995)),
        holdBuckets: 2
    )

    private let breached = MetricReading(baseline: 0, recent: [0.998, 0.996, 0.994, 0.993])
    private let healthy = MetricReading(baseline: 0, recent: [0.998, 0.996, 0.997, 0.998])

    @Test("An armed rule fires and notifies when the breach sustains")
    func fires() {
        let outcome = evaluator.evaluate(rule, reading: breached, state: .armed, now: now)

        #expect(outcome == AlertOutcome(state: .firing(since: now), shouldNotify: true))
    }

    @Test("An armed rule stays quiet while the metric is healthy")
    func staysArmed() {
        let outcome = evaluator.evaluate(rule, reading: healthy, state: .armed, now: now)

        #expect(outcome == AlertOutcome(state: .armed, shouldNotify: false))
    }

    @Test("A firing rule keeps its start date and does not notify again")
    func keepsFiring() {
        let since = Date(year: 2026, month: 7, day: 20, hour: 12)
        let outcome = evaluator.evaluate(rule, reading: breached, state: .firing(since: since), now: now)

        #expect(outcome == AlertOutcome(state: .firing(since: since), shouldNotify: false))
    }

    @Test("A firing rule re-arms silently once the breach clears")
    func recovers() {
        let since = Date(year: 2026, month: 7, day: 20, hour: 12)
        let outcome = evaluator.evaluate(rule, reading: healthy, state: .firing(since: since), now: now)

        #expect(outcome == AlertOutcome(state: .armed, shouldNotify: false))
    }

    @Test("A muted rule suppresses a sustained breach until the mute expires")
    func muted() {
        let until = Date(year: 2026, month: 7, day: 20, hour: 16)
        let outcome = evaluator.evaluate(rule, reading: breached, state: .muted(until: until), now: now)

        #expect(outcome == AlertOutcome(state: .muted(until: until), shouldNotify: false))
    }

    @Test("An expired mute evaluates again and fires anew")
    func muteExpired() {
        let until = Date(year: 2026, month: 7, day: 20, hour: 13)
        let outcome = evaluator.evaluate(rule, reading: breached, state: .muted(until: until), now: now)

        #expect(outcome == AlertOutcome(state: .firing(since: now), shouldNotify: true))
    }

    @Test("An expired mute re-arms silently when the metric is healthy")
    func muteExpiredHealthy() {
        let until = Date(year: 2026, month: 7, day: 20, hour: 13)
        let outcome = evaluator.evaluate(rule, reading: healthy, state: .muted(until: until), now: now)

        #expect(outcome == AlertOutcome(state: .armed, shouldNotify: false))
    }
}

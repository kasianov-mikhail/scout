//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct FunnelTests {
    private let funnel = Funnel(stepNames: ["open", "signup", "purchase"])

    @Test("Counts sessions that pass each step in order")
    func countsOrderedSteps() {
        let full = UUID()
        let partial = UUID()
        let events = [
            makeEvent("open", session: full, at: 0),
            makeEvent("signup", session: full, at: 1),
            makeEvent("purchase", session: full, at: 2),
            makeEvent("open", session: partial, at: 0),
            makeEvent("signup", session: partial, at: 1),
        ]

        let counts = funnel.steps(from: events).map(\.count)

        #expect(counts == [2, 2, 1])
    }

    @Test("Ignores steps that happen out of order")
    func ignoresOutOfOrderSteps() {
        let session = UUID()
        let events = [
            makeEvent("signup", session: session, at: 0),
            makeEvent("open", session: session, at: 1),
        ]

        let counts = funnel.steps(from: events).map(\.count)

        #expect(counts == [1, 0, 0])
    }

    @Test("Counts stay monotonic when a later step is frequent on its own")
    func staysMonotonic() {
        let entered = UUID()
        let stray = UUID()
        let events = [
            makeEvent("open", session: entered, at: 0),
            makeEvent("purchase", session: stray, at: 0),
            makeEvent("purchase", session: UUID(), at: 0),
        ]

        let counts = funnel.steps(from: events).map(\.count)

        #expect(counts == [1, 0, 0])
    }

    @Test("Repeated events advance the funnel only once per step")
    func repeatedEvents() {
        let session = UUID()
        let events = [
            makeEvent("open", session: session, at: 0),
            makeEvent("open", session: session, at: 1),
            makeEvent("signup", session: session, at: 2),
        ]

        let counts = funnel.steps(from: events).map(\.count)

        #expect(counts == [1, 1, 0])
    }

    @Test("Events without the correlation key are ignored")
    func ignoresEventsWithoutKey() {
        let events = [Event.sample("open", at: Date())]

        let counts = funnel.steps(from: events).map(\.count)

        #expect(counts == [0, 0, 0])
    }

    @Test("Groups by install when the install key is selected")
    func groupsByInstall() {
        let install = UUID()
        var funnel = funnel
        funnel.key = .install
        let events = [
            makeEvent("open", install: install, at: 0),
            makeEvent("signup", install: install, at: 1),
        ]

        let counts = funnel.steps(from: events).map(\.count)

        #expect(counts == [1, 1, 0])
    }

    @Test("droppedIDs returns the cohort stuck at the previous step")
    func droppedCohort() {
        let full = UUID()
        let dropped = UUID()
        let events = [
            makeEvent("open", session: full, at: 0),
            makeEvent("signup", session: full, at: 1),
            makeEvent("open", session: dropped, at: 0),
        ]

        #expect(funnel.droppedIDs(before: 1, from: events) == [dropped])
        #expect(funnel.droppedIDs(before: 0, from: events) == [])
    }

    @Test("isRunnable requires two to six steps")
    func runnableRange() {
        #expect(!Funnel(stepNames: ["a"]).isRunnable)
        #expect(Funnel(stepNames: ["a", "b"]).isRunnable)
        #expect(Funnel(stepNames: (0..<6).map(String.init)).isRunnable)
        #expect(!Funnel(stepNames: (0..<7).map(String.init)).isRunnable)
    }
}

private func makeEvent(_ name: String, session: UUID? = nil, install: UUID? = nil, at seconds: TimeInterval) -> Event {
    Event(
        name: name,
        level: nil,
        date: Date(timeIntervalSinceReferenceDate: seconds),
        paramCount: nil,
        uuid: nil,
        id: UUID().uuidString,
        installID: install,
        sessionID: session,
        deviceID: nil
    )
}

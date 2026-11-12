//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

@Suite("SessionTimeline")
struct SessionTimelineTests {
    private let start = Date(timeIntervalSince1970: 1_761_403_200)

    private func at(_ offset: TimeInterval) -> Date {
        start.addingTimeInterval(offset)
    }

    private func screen(name: String, offset: TimeInterval, duration: TimeInterval?) -> Screen {
        Screen(
            name: name,
            previous: nil,
            startDate: at(offset),
            endDate: duration.map { at(offset + $0) },
            id: UUID().uuidString,
            sessionID: nil
        )
    }

    private func resource(offset: TimeInterval) -> ResourceException {
        ResourceException(
            name: "CPU Exception",
            fingerprint: "cpu",
            reason: "92 s of CPU time in 180 s",
            stackTrace: [],
            resourceKind: .cpu,
            date: at(offset),
            id: UUID().uuidString,
            deviceID: nil,
            installID: nil,
            launchID: nil,
            sessionID: nil
        )
    }

    private func timeline(events: [Event] = [], screens: [Screen] = [], crashes: [Crash] = [], hangs: [Hang] = [], resources: [ResourceException] = [], endDate: Date? = nil, launchOpen: Bool = false) -> SessionTimeline {
        SessionTimeline(
            info: SessionInfo(startDate: start, endDate: endDate, launchOpen: launchOpen),
            events: events,
            screens: screens,
            crashes: crashes,
            hangs: hangs,
            resources: resources,
            now: at(600)
        )
    }

    @Test("rows start with the session and end with the background")
    func background() {
        let rows = timeline(endDate: at(732)).rows

        #expect(rows.first?.kind == .start)
        #expect(rows.first?.title == "Session started")
        #expect(rows.last?.kind == .end(.background))
        #expect(rows.last?.title == "Went to background")
        #expect(rows.last?.time == "+12:12")
    }

    @Test("rows stay empty without a start date")
    func noStart() {
        let timeline = SessionTimeline(info: SessionInfo(), events: [], screens: [], crashes: [], hangs: [], resources: [], now: start)
        #expect(timeline.rows.isEmpty)
    }

    @Test("events, screens, and incidents are ordered by date")
    func ordering() {
        let rows = timeline(
            events: [Event.stub(name: "later", date: at(40)), Event.stub(name: "earlier", date: at(10))],
            screens: [screen(name: "Home", offset: 20, duration: 10)]
        ).rows

        #expect(rows.map(\.title) == ["Session started", "earlier", "Home", "later", "Session end not recorded"])
    }

    @Test("a gap row separates events more than two minutes apart")
    func gap() {
        let rows = timeline(events: [Event.stub(name: "a", date: at(10)), Event.stub(name: "b", date: at(200))]).rows

        #expect(rows.map(\.title) == ["Session started", "a", "3 min 10 s", "b", "Session end not recorded"])
    }

    @Test("short pauses stay without a gap row")
    func noGap() {
        let rows = timeline(events: [Event.stub(name: "a", date: at(10)), Event.stub(name: "b", date: at(100))]).rows

        #expect(!rows.contains { $0.kind == .gap })
    }

    @Test("the last screen time leads into the session end")
    func endGap() {
        let rows = timeline(screens: [screen(name: "Home", offset: 10, duration: 60)], endDate: at(300)).rows

        #expect(rows.map(\.title) == ["Session started", "Home", "4 min 50 s", "Went to background"])
    }

    @Test("a live session ends with the live row")
    func live() {
        let rows = timeline(events: [Event.stub(name: "a", date: at(30))], launchOpen: true).rows

        #expect(rows.last?.kind == .end(.live))
        #expect(rows.last?.title == "Live")
        #expect(rows.last?.subtitle == "the device is still sending")
        #expect(rows.last?.time == "now")
    }

    @Test("a session without an end record ends with the approximate time")
    func unknownEnd() {
        let rows = timeline(events: [Event.stub(name: "a", date: at(90))]).rows

        #expect(rows.last?.kind == .end(.unknown))
        #expect(rows.last?.title == "Session end not recorded")
        #expect(rows.last?.time == "≈+1:30")
    }

    @Test("a crash ends the session")
    func crashEnd() {
        let rows = timeline(crashes: [Crash.stub(name: "NSRangeException", date: at(120))], endDate: at(130)).rows

        #expect(rows.last?.kind == .end(.crash))
        #expect(rows.last?.title == "App crashed")
        #expect(rows.last?.time == "+2:00")
    }

    @Test("screens show their duration")
    func screenDuration() {
        let rows = timeline(screens: [screen(name: "Home", offset: 10, duration: 60)], endDate: at(120)).rows

        let home = rows.first { $0.kind != .start && $0.kind != .end(.background) }
        #expect(home?.title == "Home")
        #expect(home?.subtitle == "1 min")
        #expect(home?.time == "+0:10")
    }

    @Test("an open screen shows the time so far while live")
    func liveScreenDuration() {
        let rows = timeline(screens: [screen(name: "Home", offset: 10, duration: nil)], launchOpen: true).rows

        let home = rows.first { $0.kind != .start && $0.kind != .end(.live) }
        #expect(home?.subtitle == "9 min 50 s so far")
    }

    @Test("prominent event levels keep their level")
    func levels() {
        let rows = timeline(events: [Event.stub(name: "failed", level: .error, date: at(10)), Event.stub(name: "opened", date: at(20))]).rows

        #expect(rows.first { $0.title == "failed" }?.level == .error)
        #expect(rows.first { $0.title == "opened" }?.level == nil)
    }

    @Test("incident rows carry their kind and subtitle")
    func incidents() {
        let rows = timeline(
            crashes: [Crash.stub(name: "NSRangeException", date: at(100))],
            hangs: [Hang.stub(duration: 9.2, date: at(50))],
            resources: [resource(offset: 70)]
        ).rows

        #expect(rows.first { $0.title == "Hang" }?.incident == .hang)
        #expect(rows.first { $0.title == "Hang" }?.subtitle == "9.2 s")
        #expect(rows.first { $0.title == "Crash" }?.incident == .crash)
        #expect(rows.first { $0.title == "Crash" }?.subtitle == "NSRangeException")
        #expect(rows.first { $0.title == "CPU Exception" }?.incident == .resource)
        #expect(rows.first { $0.title == "CPU Exception" }?.time == "~")
    }

    @Test("the start row names how early the app launched")
    func launchSubtitle() {
        let info = SessionInfo(startDate: start, launchDate: at(-4))
        let timeline = SessionTimeline(info: info, events: [], screens: [], crashes: [], hangs: [], resources: [], now: at(0))

        #expect(timeline.rows.first?.subtitle == "app launched 4 s before")
    }

    @Test("timeline steps and rows follow the shared list scale")
    func rowHeights() {
        let rows = timeline(
            events: [Event.stub(name: "opened", date: at(10))],
            screens: [screen(name: "Home", offset: 20, duration: 10)],
            endDate: at(100)
        ).rows

        #expect(rows.first?.height == .rowStep)
        #expect(rows.last?.height == .rowStep)
        #expect(rows.first { if case .event = $0.kind { true } else { false } }?.height == .rowRegular)
        #expect(rows.first { if case .screen = $0.kind { true } else { false } }?.height == .rowRegular)
    }
}

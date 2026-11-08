//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension TimelineSample.Records {
    static var sample: Self {
        let now = Date()
        let base = now.addingTimeInterval(-3 * 86_400)
        let deviceID = UUID()
        let install1ID = UUID()
        let install2ID = UUID()
        let launch1ID = UUID()
        let launch2ID = UUID()
        let launch3ID = UUID()
        let launch4ID = UUID()
        let launch5ID = UUID()
        let session1ID = UUID()
        let session2ID = UUID()
        let session3ID = UUID()

        func at(_ seconds: TimeInterval) -> Date {
            base.addingTimeInterval(seconds)
        }

        let crash = Crash(
            name: "SIGABRT",
            fingerprint: "crash",
            reason: "Abort",
            stackTrace: [],
            date: at(300),
            source: .inProcess,
            id: UUID().uuidString,
            deviceID: deviceID,
            installID: install1ID,
            launchID: launch1ID,
            sessionID: session1ID
        )

        let launchCrash = Crash(
            name: "Watchdog Termination",
            fingerprint: "watchdog",
            reason: nil,
            stackTrace: [],
            date: at(20 * 3_600),
            source: .metricKit(windowStart: at(19 * 3_600)),
            id: UUID().uuidString,
            deviceID: deviceID,
            installID: install1ID,
            launchID: launch3ID,
            sessionID: nil
        )

        let hang = Hang(
            name: "Main Thread Blocked",
            fingerprint: "hang",
            reason: nil,
            stackTrace: [],
            duration: 0.6,
            date: at(200),
            id: UUID().uuidString,
            deviceID: deviceID,
            installID: install1ID,
            launchID: launch1ID,
            sessionID: session1ID
        )

        let resource = ResourceException(
            name: "CPU Exception",
            fingerprint: "cpu",
            reason: "92 s of CPU time in 180 s",
            stackTrace: [],
            resourceKind: .cpu,
            date: at(21 * 3_600 + 3_600 + 240),
            id: UUID().uuidString,
            deviceID: deviceID,
            installID: install1ID,
            launchID: launch4ID,
            sessionID: session2ID
        )

        let versions = [
            Version(
                appVersion: "2.4.0",
                buildNumber: "210",
                launchID: launch1ID,
                date: at(60),
                id: UUID().uuidString
            ),
            Version(
                appVersion: "2.4.1",
                buildNumber: "214",
                launchID: launch4ID,
                date: at(21 * 3_600),
                id: UUID().uuidString
            ),
            Version(
                appVersion: "2.4.1",
                buildNumber: "214",
                launchID: launch5ID,
                date: at(2 * 86_400 + 60),
                id: UUID().uuidString
            ),
        ]

        let rail = Rail(
            device: Device(date: base, id: deviceID.uuidString, deviceID: deviceID),
            installs: [
                Install(date: at(0), id: install1ID.uuidString, installID: install1ID, deviceID: deviceID),
                Install(
                    date: at(2 * 86_400), id: install2ID.uuidString, installID: install2ID, deviceID: deviceID),
            ],
            launches: [
                Launch(startDate: at(60), endDate: nil, id: launch1ID.uuidString, launchID: launch1ID, installID: install1ID),
                Launch(
                    startDate: at(3 * 3_600), endDate: at(3 * 3_600 + 120), id: launch2ID.uuidString,
                    launchID: launch2ID, installID: install1ID),
                Launch(
                    startDate: at(20 * 3_600), endDate: nil, id: launch3ID.uuidString, launchID: launch3ID,
                    installID: install1ID),
                Launch(
                    startDate: at(20 * 3_600 + 2_700), endDate: nil, id: launch4ID.uuidString, launchID: launch4ID,
                    installID: install1ID),
                Launch(
                    startDate: at(2 * 86_400 + 60), endDate: nil, id: launch5ID.uuidString, launchID: launch5ID,
                    installID: install2ID),
            ],
            sessions: [
                Session(
                    startDate: at(90), endDate: at(300), id: session1ID.uuidString, sessionID: session1ID,
                    launchID: launch1ID, installID: install1ID),
                Session(
                    startDate: at(20 * 3_600 + 2_730), endDate: nil, id: session2ID.uuidString, sessionID: session2ID,
                    launchID: launch4ID, installID: install1ID),
                Session(
                    startDate: at(2 * 86_400 + 90), endDate: nil, id: session3ID.uuidString, sessionID: session3ID,
                    launchID: launch5ID, installID: install2ID),
            ],
            events: [
                Event(
                    name: "app_open", level: nil, date: at(95), paramCount: nil, uuid: nil,
                    id: UUID().uuidString, installID: install1ID, sessionID: session1ID, deviceID: deviceID),
                Event(
                    name: "screen_view", level: nil, date: at(98), paramCount: nil, uuid: nil,
                    id: UUID().uuidString, installID: install1ID, sessionID: session1ID, deviceID: deviceID),
                Event(
                    name: "app_open", level: nil, date: at(20 * 3_600 + 2_735), paramCount: nil, uuid: nil,
                    id: UUID().uuidString, installID: install1ID, sessionID: session2ID, deviceID: deviceID),
                Event(
                    name: "feed_scroll", level: nil, date: at(20 * 3_600 + 2_800), paramCount: nil, uuid: nil,
                    id: UUID().uuidString, installID: install1ID, sessionID: session2ID, deviceID: deviceID),
                Event(
                    name: "app_open", level: nil, date: at(2 * 86_400 + 95), paramCount: nil, uuid: nil,
                    id: UUID().uuidString, installID: install2ID, sessionID: session3ID, deviceID: deviceID),
                Event(
                    name: "onboarding_start", level: nil, date: at(2 * 86_400 + 101), paramCount: nil, uuid: nil,
                    id: UUID().uuidString, installID: install2ID, sessionID: session3ID, deviceID: deviceID),
            ],
            crashes: [crash, launchCrash]
        )

        return Self(
            rail: rail,
            incidents: TimelineIncidents(
                crashes: [crash, launchCrash],
                hangs: [hang],
                resources: [resource],
                versions: versions
            )
        )
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoIncidents {
    struct Point {
        let date: Date
        let version: String
        let installID: UUID
    }

    let records: [Record]
    let crashes: [Point]
    let hangs: [Point]
    let resources: [ResourceKind: [Point]]

    init(scenario: DemoScenario) {
        var random = DemoRandom(seed: 0xDEAD_FA11)
        var records: [Record] = []
        var crashes: [Point] = []
        var hangs: [Point] = []

        let crashProne = Set(
            stride(from: 0, to: scenario.installs.count, by: 63).map { scenario.installs[$0].id }
        )

        let latestCrashProne = Set(
            stride(from: 0, to: scenario.installs.count, by: 240).map { scenario.installs[$0].id }
        )

        let latest = scenario.versions.last?.version

        for session in scenario.sessions {
            let isLatest = session.version.version == latest
            let span = max(1, session.end.timeIntervalSince(session.start))

            if (isLatest ? latestCrashProne : crashProne).contains(session.install.id), random.double(in: 0...1) < (isLatest ? 0.7 : 0.4) {
                let signature = Self.crashSignatures[random.int(in: 0...Self.crashSignatures.count - 1)]
                let date = session.start.addingTimeInterval(random.double(in: 0...span))
                let id = random.uuid()

                records.append(
                    session.versioned(
                        Crash(
                            name: signature.name,
                            fingerprint: "crash-\(signature.name)",
                            reason: signature.reason,
                            stackTrace: signature.frames,
                            date: date,
                            source: .inProcess,
                            id: id.uuidString,
                            deviceID: session.device.id,
                            installID: session.install.id,
                            launchID: session.launchID,
                            sessionID: session.id
                        )
                        .record
                    )
                )
                crashes.append(Point(date: date, version: session.version.version, installID: session.install.id))
            }

            if random.double(in: 0...1) < 0.012 {
                let signature = Self.hangSignatures[random.int(in: 0...Self.hangSignatures.count - 1)]
                let date = session.start.addingTimeInterval(random.double(in: 0...span))
                let id = random.uuid()

                records.append(
                    session.versioned(
                        Hang(
                            name: signature.name,
                            fingerprint: CrashFingerprint(name: signature.name, reason: nil, stackTrace: signature.frames).value,
                            reason: signature.reason,
                            stackTrace: signature.frames,
                            duration: random.double(in: 0.3...6),
                            date: date,
                            id: id.uuidString,
                            deviceID: session.device.id,
                            installID: session.install.id,
                            launchID: session.launchID,
                            sessionID: session.id
                        )
                        .record
                    )
                )
                hangs.append(Point(date: date, version: session.version.version, installID: session.install.id))
            }
        }

        let resourceResult = Self.resourceRecords(sessions: scenario.sessions)

        self.records = records + resourceResult.records
        self.crashes = crashes
        self.hangs = hangs
        self.resources = resourceResult.resources
    }
}

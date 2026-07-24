//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoScenario {
    struct AppVersion {
        let version: String
        let build: String
        let releasedDaysAgo: Int
    }

    struct DeviceInfo {
        let id: UUID
        let model: String
        let os: String
    }

    struct InstallInfo {
        let id: UUID
        let device: DeviceInfo
        let date: Date
        let version: AppVersion
        let locale: String
        let channel: String
    }

    struct SessionInfo {
        let id: UUID
        let install: InstallInfo
        let launchID: UUID
        let start: Date
        let end: Date
        let version: AppVersion

        var device: DeviceInfo { install.device }
    }

    static let installCount = 300
    static let spanDays = 120

    let clock: DemoClock
    let versions: [AppVersion]
    let installs: [InstallInfo]
    let sessions: [SessionInfo]

    var devices: [DeviceInfo] {
        installs.map(\.device)
    }

    var adoption: [(version: String, date: Date)] {
        var seen: Set<String> = []
        return sessions.compactMap { session in
            guard seen.insert("\(session.install.id)-\(session.version.version)").inserted else {
                return nil
            }
            return (session.version.version, session.start)
        }
    }

    init(clock: DemoClock) {
        self.clock = clock
        var random = DemoRandom(seed: 0x5C0_17_DE_A11)

        let versions = [
            AppVersion(version: "2.1.0", build: "210", releasedDaysAgo: 64),
            AppVersion(version: "2.2.0", build: "220", releasedDaysAgo: 35),
            AppVersion(version: "2.3.0", build: "230", releasedDaysAgo: 12),
        ]
        self.versions = versions

        let models = [
            ("iPhone 15 Pro", "17.5.1"),
            ("iPhone 14", "17.4.1"),
            ("iPhone SE (3rd generation)", "16.7.8"),
            ("iPad Pro 11-inch", "17.5"),
            ("iPhone 13 mini", "17.3.1"),
            ("iPhone 15", "18.0"),
            ("iPad Air", "17.4"),
            ("iPhone 12", "16.6.1"),
        ]
        let locales = ["en_US", "en_GB", "de_DE", "fr_FR", "ja_JP", "es_ES"]
        let channels = ["AppStore", "AppStore", "AppStore", "TestFlight"]

        func activeVersion(daysAgo: Int) -> AppVersion {
            versions.filter { $0.releasedDaysAgo >= daysAgo }
                .min { $0.releasedDaysAgo < $1.releasedDaysAgo } ?? versions[0]
        }

        var installs: [InstallInfo] = []
        var sessions: [SessionInfo] = []

        for index in 0..<Self.installCount {
            let installDaysAgo = index * Self.spanDays / Self.installCount
            let model = models[index % models.count]

            let install = InstallInfo(
                id: random.uuid(),
                device: DeviceInfo(id: random.uuid(), model: model.0, os: model.1),
                date: clock.momentDaysAgo(installDaysAgo),
                version: activeVersion(daysAgo: installDaysAgo),
                locale: locales[index % locales.count],
                channel: channels[index % channels.count]
            )
            installs.append(install)

            var activeDays = [0]
            for (milestone, offset) in [1, 3, 7, 14, 30].enumerated() where installDaysAgo - offset >= 0 {
                let keepChance = 0.82 - Double(milestone) * 0.14

                if random.double(in: 0...1) < keepChance {
                    activeDays.append(offset)
                }
            }

            for offset in activeDays {
                let sessionDaysAgo = installDaysAgo - offset

                for _ in 0..<random.int(in: 1...3) {
                    let start = clock.moment(
                        daysAgo: sessionDaysAgo,
                        spread: random.double(in: -5 * 3600...5 * 3600),
                        after: install.date
                    )
                    let end = min(
                        start.addingTimeInterval(random.double(in: 45...2100)),
                        clock.now.addingTimeInterval(-1)
                    )

                    sessions.append(
                        SessionInfo(
                            id: random.uuid(),
                            install: install,
                            launchID: random.uuid(),
                            start: start,
                            end: end,
                            version: activeVersion(daysAgo: sessionDaysAgo)
                        )
                    )
                }
            }
        }

        self.installs = installs
        self.sessions = sessions
    }

    var records: [Record] {
        deviceRecords + installRecords + launchRecords + sessionRecords
    }

    private var deviceRecords: [Record] {
        installs.map { install in
            var record = Device(
                date: install.date,
                id: install.device.id.uuidString,
                deviceID: install.device.id
            )
            .record
            record["model"] = install.device.model
            return record
        }
    }

    private var installRecords: [Record] {
        installs.map { install in
            Install(
                date: install.date,
                id: install.id.uuidString,
                installID: install.id,
                deviceID: install.device.id
            )
            .record
        }
    }

    private var launchRecords: [Record] {
        sessions.map { session in
            var record = Launch(
                startDate: session.start,
                endDate: session.end,
                id: session.launchID.uuidString,
                launchID: session.launchID,
                installID: session.install.id
            )
            .record
            record["device_id"] = session.device.id.uuidString
            return record
        }
    }

    private var sessionRecords: [Record] {
        sessions.map { session in
            var record = Session(
                startDate: session.start,
                endDate: session.end,
                id: session.id.uuidString,
                sessionID: session.id,
                launchID: session.launchID,
                installID: session.install.id
            )
            .record

            record["device_id"] = session.device.id.uuidString
            record["os_version"] = session.device.os
            record["app_version"] = session.version.version
            record["build_number"] = session.version.build
            record["locale"] = session.install.locale
            record["channel"] = session.install.channel
            return record
        }
    }
}

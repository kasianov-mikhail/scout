//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension DemoScenario {
    init(clock: DemoClock) {
        self.clock = clock
        var random = DemoRandom(seed: 0x5C0_17_DE_A11)

        let versions = [
            AppVersion(version: "2.1.0", build: "210", releasedDaysAgo: 120),
            AppVersion(version: "2.2.0", build: "220", releasedDaysAgo: 62),
            AppVersion(version: "2.3.0", build: "230", releasedDaysAgo: 26),
        ]
        self.versions = versions

        let models = [
            ("iPhone 17 Pro", "iOS 26.0.1"),
            ("iPhone 16", "iOS 26.0"),
            ("iPhone 17 Pro", "iOS 26.0.1"),
            ("iPhone 17 Pro Max", "iOS 26.0.1"),
            ("iPhone 16", "iOS 26.0"),
            ("iPhone Air", "iOS 26.0.1"),
            ("iPhone 17 Pro", "iOS 26.0"),
            ("iPhone 15 Pro", "iOS 18.6.2"),
            ("iPhone 17 Pro Max", "iOS 26.0"),
            ("iPad Pro", "iPadOS 26.0"),
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
            let installDaysAgo = Int(Double(Self.spanDays) * pow(Double(index) / Double(Self.installCount), 1.15))
            let model = models[index % models.count]

            let install = InstallInfo(
                id: random.uuid(),
                device: DeviceInfo(id: random.uuid(), model: model.0, os: model.1),
                date: clock.momentDaysAgo(installDaysAgo),
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
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoReleases {
    let samples: [DemoSample]

    init(scenario: DemoScenario, incidents: DemoIncidents) {
        var samples: [DemoSample] = []

        samples += scenario.sessions.map {
            DemoSample(name: SessionEntry.recordType, version: $0.version.version, source: .lifecycle, date: $0.start)
        }
        samples += incidents.crashes.map {
            DemoSample(name: CrashEntry.recordType, version: $0.version, source: .lifecycle, date: $0.date)
        }
        samples += incidents.hangs.map {
            DemoSample(name: HangEntry.recordType, version: $0.version, source: .lifecycle, date: $0.date)
        }
        samples += scenario.adoption.map {
            DemoSample(name: VersionEntry.recordType, version: $0.version, source: .lifecycle, date: $0.date)
        }

        samples += DemoReleases.crashedInstalls(incidents.crashes)
        samples += DemoReleases.exits(sessions: scenario.sessions, crashes: incidents.crashes)

        self.samples = samples
    }

    private static func exits(sessions: [DemoScenario.SessionInfo], crashes: [DemoIncidents.Point]) -> [DemoSample] {
        var random = DemoRandom(seed: 0xE817_0DA7)

        let ended = sessions.map { session in
            DemoSample(
                name: ExitReason.metricName,
                category: random.exitReason().rawValue,
                version: session.version.version,
                source: .lifecycle,
                date: session.end
            )
        }

        let crashed = crashes.map { crash in
            DemoSample(
                name: ExitReason.metricName,
                category: ExitReason.badAccess.rawValue,
                version: crash.version,
                source: .lifecycle,
                date: crash.date
            )
        }

        return ended + crashed
    }

    private static func crashedInstalls(_ crashes: [DemoIncidents.Point]) -> [DemoSample] {
        var seen: Set<String> = []
        return crashes.compactMap { crash in
            guard seen.insert("\(crash.installID)-\(crash.version)").inserted else {
                return nil
            }
            return DemoSample(
                name: MarkerEntry.crashName,
                version: crash.version,
                source: .lifecycle,
                date: crash.date
            )
        }
    }
}

extension DemoRandom {
    fileprivate mutating func exitReason() -> ExitReason {
        switch double(in: 0...1) {
        case ..<0.004:
            .memoryLimit
        case ..<0.006:
            .watchdog
        case ..<0.35:
            .memoryPressure
        default:
            .normal
        }
    }
}

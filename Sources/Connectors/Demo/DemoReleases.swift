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
            DemoSample(name: SessionEntry.recordType, version: $0.version.version, date: $0.start)
        }
        samples += incidents.crashes.map {
            DemoSample(name: CrashEntry.recordType, version: $0.version, date: $0.date)
        }
        samples += incidents.hangs.map {
            DemoSample(name: HangEntry.recordType, version: $0.version, date: $0.date)
        }
        samples += scenario.adoption.map {
            DemoSample(name: VersionEntry.recordType, version: $0.version, date: $0.date)
        }
        samples += DemoReleases.crashedInstalls(incidents.crashes)

        self.samples = samples
    }

    private static func crashedInstalls(_ crashes: [DemoIncidents.Point]) -> [DemoSample] {
        var seen: Set<String> = []
        return crashes.compactMap { crash in
            guard seen.insert("\(crash.installID)-\(crash.version)").inserted else {
                return nil
            }
            return DemoSample(name: MarkerEntry.crashName, version: crash.version, date: crash.date)
        }
    }
}

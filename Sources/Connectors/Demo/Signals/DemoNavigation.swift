//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoNavigation {
    static let transitions = [
        "Home": ["Search", "Feed", "Profile", "Settings"],
        "Search": ["Item", "Home"],
        "Feed": ["Item", "Home"],
        "Item": ["Checkout", "Feed", "Search"],
        "Checkout": ["Home"],
        "Profile": ["Settings", "Home"],
        "Settings": ["Profile", "Home"],
    ]

    let records: [Record]
    let samples: [DemoSample]

    init(scenario: DemoScenario) {
        var random = DemoRandom(seed: 0x5C2E_E45)
        var records: [Record] = []
        var samples: [DemoSample] = []

        for session in scenario.sessions {
            let count = random.int(in: 1...5)
            let step = max(1, session.end.timeIntervalSince(session.start)) / Double(count)
            var name = "Home"
            var previous: String?

            for index in 0..<count {
                let start = session.start.addingTimeInterval(step * Double(index))
                let id = random.uuid()

                var record = Record(recordType: ScreenEntry.recordType, recordID: id.uuidString)
                record["category"] = name
                record["previous"] = previous
                record["date"] = start
                record["end_date"] = start.addingTimeInterval(step)
                record["uuid"] = id.uuidString
                record["session_id"] = session.id.uuidString
                record["launch_id"] = session.launchID.uuidString
                record["install_id"] = session.install.id.uuidString
                record["device_id"] = session.device.id.uuidString

                records.append(session.versioned(record))
                samples.append(
                    DemoSample(
                        name: ScreenEntry.recordType,
                        category: name,
                        version: session.version.version,
                        source: .lifecycle,
                        date: start
                    )
                )

                let next = DemoNavigation.transitions[name] ?? ["Home"]
                previous = name
                name = next[random.int(in: 0...next.count - 1)]
            }
        }

        self.records = records
        self.samples = samples
    }
}

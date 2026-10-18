//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoConditions {
    let records: [Record]
    let samples: [DemoSample]

    init(scenario: DemoScenario) {
        var random = DemoRandom(seed: 0xC0_4D_17)
        var records: [Record] = []
        var samples: [DemoSample] = []

        for session in scenario.sessions {
            let span = max(1, session.end.timeIntervalSince(session.start))
            var conditions: [DatedCondition] = []

            if random.int(in: 1...10) == 1 {
                conditions.append(DatedCondition(condition: .lowPowerOn, date: session.start))
            }
            if random.int(in: 1...12) == 1 {
                let heat = session.start.addingTimeInterval(random.double(in: 0...span / 2))
                conditions.append(DatedCondition(condition: .thermalSerious, date: heat))
                conditions.append(DatedCondition(condition: .thermalNominal, date: heat.addingTimeInterval(span / 4)))
            }
            if random.int(in: 1...8) == 1 {
                conditions.append(DatedCondition(condition: .memoryWarning, date: session.start.addingTimeInterval(random.double(in: 0...span))))
            }

            for dated in conditions {
                let id = random.uuid()

                var record = Record(recordType: ConditionEntry.recordType, recordID: id.uuidString)
                record["category"] = dated.condition.rawValue
                record["value"] = dated.condition == .memoryWarning ? random.double(in: 40...180) * 1_048_576 : 0
                record["date"] = dated.date
                record["uuid"] = id.uuidString
                record["session_id"] = session.id.uuidString
                record["launch_id"] = session.launchID.uuidString
                record["install_id"] = session.install.id.uuidString
                record["device_id"] = session.device.id.uuidString

                records.append(session.versioned(record))
                samples.append(
                    DemoSample(
                        name: ConditionEntry.recordType,
                        category: dated.condition.rawValue,
                        version: session.version.version,
                        source: .lifecycle,
                        date: dated.date
                    )
                )
            }
        }

        self.records = records
        self.samples = samples
    }
}

private struct DatedCondition {
    let condition: Condition
    let date: Date
}

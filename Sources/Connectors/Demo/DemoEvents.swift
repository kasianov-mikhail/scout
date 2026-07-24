//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoEvents {
    static let names = [
        "Search_Performed",
        "Item_Viewed",
        "Purchase_Completed",
        "Onboarding_Finished",
        "Share_Tapped",
        "Settings_Opened",
        "Notification_Received",
        "Sync_Failed",
    ]

    let records: [Record]
    let samples: [DemoSample]

    init(scenario: DemoScenario) {
        var random = DemoRandom(seed: 0xE_1E_17_5)
        var records: [Record] = []
        var samples: [DemoSample] = []

        let encoder = JSONEncoder()

        let paramPools: [String: [String: [String]]] = [
            "Search_Performed": ["query": ["coffee", "sneakers", "flights"], "result_count": ["0", "8", "23"]],
            "Item_Viewed": ["item_id": ["SKU-1042", "SKU-2231"], "category": ["shoes", "audio", "home"]],
            "Purchase_Completed": ["amount": ["4.99", "19.99", "49.00"], "currency": ["USD", "EUR", "GBP"]],
            "Onboarding_Finished": ["steps": ["3", "4"], "skipped": ["true", "false"]],
            "Share_Tapped": ["destination": ["messages", "mail", "twitter"]],
            "Settings_Opened": ["section": ["privacy", "notifications", "account"]],
            "Notification_Received": ["kind": ["promo", "reminder", "digest"]],
            "Sync_Failed": ["reason": ["timeout", "offline", "server_error"], "attempt": ["1", "2", "3"]],
        ]

        let levels: [EventLevel] = [.info, .info, .info, .notice, .warning, .error]

        for (index, session) in scenario.sessions.enumerated() {
            let span = max(1, session.end.timeIntervalSince(session.start))

            for _ in 0..<random.int(in: 0...2) {
                let name = DemoEvents.names[random.int(in: 0...DemoEvents.names.count - 1)]
                let date = session.start.addingTimeInterval(random.double(in: 0...span))
                let level = name == "Sync_Failed" ? EventLevel.error : levels[index % levels.count]

                var params: [String: String] = [:]
                for (key, options) in paramPools[name] ?? [:] {
                    params[key] = options[random.int(in: 0...options.count - 1)]
                }

                let id = random.uuid()
                var record = Event(
                    name: name,
                    level: level,
                    date: date,
                    paramCount: params.count,
                    uuid: id,
                    id: id.uuidString,
                    installID: session.install.id,
                    sessionID: session.id,
                    deviceID: session.device.id
                )
                .record

                record["params"] = try? encoder.encode(params)
                records.append(record)
                samples.append(DemoSample(name: name, date: date))
            }
        }

        self.records = records
        self.samples = samples
    }
}

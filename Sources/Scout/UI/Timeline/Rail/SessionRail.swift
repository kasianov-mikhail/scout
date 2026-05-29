//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct SessionRail: Identifiable {
    let session: Session
    let events: [Event]
    let crashes: [Crash]

    var id: CKRecord.ID { session.id }
}

extension SessionRail {
    static var sample: SessionRail {
        let start = Date().addingTimeInterval(-300)
        return SessionRail(
            session: .sample(at: start),
            events: [
                .sample("setup", at: start.addingTimeInterval(20)),
                .sample("ip_lookup", at: start.addingTimeInterval(80)),
                .sample("search", at: start.addingTimeInterval(160)),
            ],
            crashes: []
        )
    }

    static var crashed: SessionRail {
        let start = Date().addingTimeInterval(-200)
        return SessionRail(
            session: .sample(at: start),
            events: [.sample("ip_lookup", at: start.addingTimeInterval(30))],
            crashes: [.sample("SIGABRT", at: start.addingTimeInterval(90))]
        )
    }
}

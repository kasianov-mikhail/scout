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

    init(scenario: DemoScenario) {
        var random = DemoRandom(seed: 0xDEAD_FA11)
        var records: [Record] = []
        var crashes: [Point] = []
        var hangs: [Point] = []

        let crashSignatures: [(name: String, reason: String, frames: [String])] = [
            (
                "EXC_BAD_ACCESS", "Attempted to dereference a nil value",
                ["FeedViewController.reload()", "DataSource.item(at:)", "Array.subscript.getter"]
            ),
            (
                "NSInvalidArgumentException", "-[__NSCFString objectForKey:]: unrecognized selector",
                ["ProfileStore.decode()", "JSONDecoder.decode(_:from:)", "objc_exception_throw"]
            ),
            (
                "SIGABRT", "Fatal error: Index out of range",
                ["Paginator.page(_:)", "Array.subscript.getter", "CheckoutView.body.getter"]
            ),
            (
                "EXC_BREAKPOINT", "Swift runtime failure: force unwrap of nil",
                ["PaymentCoordinator.confirm()", "Optional.unsafelyUnwrapped", "Wallet.charge(_:)"]
            ),
        ]

        let hangSignatures: [(name: String, reason: String, frames: [String])] = [
            (
                "Main thread blocked", "Synchronous network request on the main queue",
                ["SyncManager.flush()", "URLSession.dataTask(with:)", "RunLoop.run()"]
            ),
            (
                "Main thread blocked", "Heavy image decode during scroll",
                ["ImageCache.decode(_:)", "UIImage.init(data:)", "CATransaction.commit()"]
            ),
            (
                "Main thread blocked", "Large Core Data fetch on the main context",
                ["Library.reload()", "NSManagedObjectContext.fetch(_:)", "sqlite3_step"]
            ),
            (
                "Main thread blocked", "JSON parse of a large payload",
                ["Importer.run()", "JSONSerialization.jsonObject(with:)", "memmove"]
            ),
        ]

        let crashProne = Set(
            stride(from: 0, to: scenario.installs.count, by: 60).map { scenario.installs[$0].id }
        )

        for session in scenario.sessions {
            let span = max(1, session.end.timeIntervalSince(session.start))

            if crashProne.contains(session.install.id), random.double(in: 0...1) < 0.4 {
                let signature = crashSignatures[random.int(in: 0...crashSignatures.count - 1)]
                let date = session.start.addingTimeInterval(random.double(in: 0...span))
                let id = random.uuid()

                var record = Crash(
                    name: signature.name,
                    fingerprint: "crash-\(signature.name)",
                    reason: signature.reason,
                    stackTrace: signature.frames,
                    date: date,
                    id: id.uuidString,
                    deviceID: session.device.id,
                    installID: session.install.id,
                    launchID: session.launchID,
                    sessionID: session.id
                )
                .record

                record["app_version"] = session.version.version
                records.append(record)
                crashes.append(Point(date: date, version: session.version.version, installID: session.install.id))
            }

            if random.double(in: 0...1) < 0.012 {
                let signature = hangSignatures[random.int(in: 0...hangSignatures.count - 1)]
                let date = session.start.addingTimeInterval(random.double(in: 0...span))
                let id = random.uuid()

                var record = Hang(
                    name: signature.name,
                    fingerprint: "hang-\(signature.reason)",
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

                record["app_version"] = session.version.version
                records.append(record)
                hangs.append(Point(date: date, version: session.version.version, installID: session.install.id))
            }
        }

        self.records = records
        self.crashes = crashes
        self.hangs = hangs
    }
}

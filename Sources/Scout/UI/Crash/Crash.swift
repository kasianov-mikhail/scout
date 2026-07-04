//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Crash: Identifiable {
    let name: String
    let fingerprint: String
    let reason: String?
    let stackTrace: [String]
    let date: Date?
    let id: String
    let deviceID: UUID?
    let installID: UUID?
    let launchID: UUID?
    let sessionID: UUID?
}

extension Crash: Comparable {
    static func < (lhs: Crash, rhs: Crash) -> Bool {
        (lhs.date ?? .distantPast) > (rhs.date ?? .distantPast)
    }
}

extension Crash: RecordDecodable {
    static let recordType = CrashObject.recordType

    static let desiredKeys = [
        "name",
        "fingerprint",
        "reason",
        "stack_trace",
        "date",
        "uuid",
        "device_id",
        "install_id",
        "launch_id",
        "session_id",
    ]
}

extension Crash {
    init(record: Record) throws {
        name = record["name"] ?? ""
        reason = record["reason"]
        date = record["date"]
        id = record.recordID
        deviceID = record["device_id"].flatMap(UUID.init)
        installID = record["install_id"].flatMap(UUID.init)
        launchID = record["launch_id"].flatMap(UUID.init)
        sessionID = record["session_id"].flatMap(UUID.init)

        if let data: Data = record["stack_trace"], let decoded = try? JSONDecoder().decode([String].self, from: data) {
            stackTrace = decoded
        } else {
            stackTrace = []
        }
        fingerprint = record["fingerprint"] ?? CrashFingerprint(name: name, reason: reason, stackTrace: stackTrace).value
    }
}

extension Crash {
    static var sample: Crash {
        Self.sample("NSRangeException", at: Date())
    }

    static func sample(_ name: String, at date: Date, sessionID: UUID? = nil) -> Crash {
        Crash(
            name: name,
            fingerprint: CrashFingerprint(name: name, reason: nil, stackTrace: []).value,
            reason: nil,
            stackTrace: [],
            date: date,
            id: UUID().uuidString,
            deviceID: nil,
            installID: nil,
            launchID: nil,
            sessionID: sessionID
        )
    }

    static var sampleRecords: [Record] {
        let deviceX = UUID()
        let deviceY = UUID()

        let sessionA = UUID()
        let sessionB = UUID()
        let sessionC = UUID()

        return [
            sampleRecord(
                name: "NSRangeException",
                reason: "-[__NSArrayM objectAtIndex:]: index 4 beyond bounds [0 .. 2]",
                minutesAgo: 6,
                deviceID: deviceX,
                sessionID: sessionA,
                stackTrace: rangeStackTrace
            ),
            sampleRecord(
                name: "NSRangeException",
                reason: "-[__NSArrayM objectAtIndex:]: index 4 beyond bounds [0 .. 2]",
                minutesAgo: 95,
                deviceID: deviceX,
                sessionID: sessionB,
                stackTrace: rangeStackTrace
            ),
            sampleRecord(
                name: "NSRangeException",
                reason: "-[__NSArrayM objectAtIndex:]: index 4 beyond bounds [0 .. 2]",
                minutesAgo: 340,
                deviceID: deviceX,
                sessionID: sessionA,
                stackTrace: rangeStackTrace
            ),
            sampleRecord(
                name: "Fatal error",
                reason: "Index out of range",
                minutesAgo: 42,
                deviceID: deviceX,
                sessionID: sessionB,
                stackTrace: fatalStackTrace
            ),
            sampleRecord(
                name: "Fatal error",
                reason: "Index out of range",
                minutesAgo: 220,
                deviceID: deviceY,
                sessionID: sessionC,
                stackTrace: fatalStackTrace
            ),
            sampleRecord(
                name: "SIGSEGV",
                reason: "Segmentation fault: 11",
                minutesAgo: 1500,
                deviceID: deviceY,
                sessionID: sessionC,
                stackTrace: segvStackTrace
            ),
        ]
    }

    private static func sampleRecord(name: String, reason: String, minutesAgo: Double, deviceID: UUID, sessionID: UUID, stackTrace: [String]) -> Record {
        var record = Record(recordType: recordType, recordID: UUID().uuidString)
        record["name"] = name
        record["reason"] = reason
        record["date"] = Date(timeIntervalSinceNow: -minutesAgo * 60)
        record["device_id"] = deviceID.uuidString
        record["session_id"] = sessionID.uuidString
        record["install_id"] = UUID().uuidString
        record["launch_id"] = UUID().uuidString
        record["stack_trace"] = try? JSONEncoder().encode(stackTrace)
        return record
    }

    private static let rangeStackTrace = [
        "0   CoreFoundation        0x0 __exceptionPreprocess + 164",
        "1   libobjc.A.dylib       0x0 objc_exception_throw + 60",
        "2   CoreFoundation        0x0 -[__NSArrayM objectAtIndex:] + 1228",
        "3   Scout                 0x0 FeedViewController.row(at:) + 88",
    ]

    private static let fatalStackTrace = [
        "0   Scout                 0x0 Scout.Cart.total.getter + 240",
        "1   Scout                 0x0 Scout.CheckoutView.body.getter + 132",
        "2   SwiftUI               0x0 closure #1 in ViewBody.render + 96",
    ]

    private static let segvStackTrace = [
        "0   Scout                 0x0 ImageLoader.decode(_:) + 512",
        "1   Scout                 0x0 closure #1 in ImageLoader.load() + 96",
    ]
}

extension [Crash] {
    static var samples: [Crash] {
        let counts: KeyValuePairs<String, Int> = ["NSRangeException": 8, "Fatal error": 4, "SIGSEGV": 2]

        var crashes: [Crash] = []
        var index = 0

        for (name, count) in counts {
            for _ in 0..<count {
                let date = Date(timeIntervalSinceNow: -Double(index % 13) * 86_400 - Double(index) * 600)
                crashes.append(.sample(name, at: date, sessionID: UUID()))
                index += 1
            }
        }

        return crashes
    }
}

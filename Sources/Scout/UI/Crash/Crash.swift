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
        sample(.nsRange, minutesAgo: 0)
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

        let crashes = [
            sample(.nsRange, minutesAgo: 6, deviceID: deviceX, sessionID: sessionA),
            sample(.nsRange, minutesAgo: 95, deviceID: deviceX, sessionID: sessionB),
            sample(.nsRange, minutesAgo: 340, deviceID: deviceX, sessionID: sessionA),
            sample(.fatal, minutesAgo: 42, deviceID: deviceX, sessionID: sessionB),
            sample(.fatal, minutesAgo: 220, deviceID: deviceY, sessionID: sessionC),
            sample(.segv, minutesAgo: 1500, deviceID: deviceY, sessionID: sessionC),
        ]

        return crashes.map(\.record)
    }

    private static func sample(_ kind: Kind, minutesAgo: Double, deviceID: UUID = UUID(), sessionID: UUID = UUID()) -> Crash {
        Crash(
            name: kind.name,
            fingerprint: CrashFingerprint(name: kind.name, reason: kind.reason, stackTrace: kind.stackTrace).value,
            reason: kind.reason,
            stackTrace: kind.stackTrace,
            date: Date(timeIntervalSinceNow: -minutesAgo * 60),
            id: UUID().uuidString,
            deviceID: deviceID,
            installID: UUID(),
            launchID: UUID(),
            sessionID: sessionID
        )
    }

    private var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["name"] = name
        record["fingerprint"] = fingerprint
        record["reason"] = reason
        record["stack_trace"] = try? JSONEncoder().encode(stackTrace)
        record["date"] = date
        record["device_id"] = deviceID?.uuidString
        record["install_id"] = installID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["session_id"] = sessionID?.uuidString
        return record
    }

    private struct Kind {
        let name: String
        let reason: String
        let stackTrace: [String]

        static let nsRange = Kind(
            name: "NSRangeException",
            reason: "-[__NSArrayM objectAtIndex:]: index 4 beyond bounds [0 .. 2]",
            stackTrace: [
                "0   CoreFoundation        0x0 __exceptionPreprocess + 164",
                "1   libobjc.A.dylib       0x0 objc_exception_throw + 60",
                "2   CoreFoundation        0x0 -[__NSArrayM objectAtIndex:] + 1228",
                "3   Scout                 0x0 FeedViewController.row(at:) + 88",
            ]
        )

        static let fatal = Kind(
            name: "Fatal error",
            reason: "Index out of range",
            stackTrace: [
                "0   Scout                 0x0 Scout.Cart.total.getter + 240",
                "1   Scout                 0x0 Scout.CheckoutView.body.getter + 132",
                "2   SwiftUI               0x0 closure #1 in ViewBody.render + 96",
            ]
        )

        static let segv = Kind(
            name: "SIGSEGV",
            reason: "Segmentation fault: 11",
            stackTrace: [
                "0   Scout                 0x0 ImageLoader.decode(_:) + 512",
                "1   Scout                 0x0 closure #1 in ImageLoader.load() + 96",
            ]
        )
    }
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

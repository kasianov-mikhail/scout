//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension DemoIncidents {
    static func resourceRecords(
        sessions: [DemoScenario.SessionInfo]
    ) -> (records: [Record], resources: [ResourceKind: [Point]]) {
        var resourceRandom = DemoRandom(seed: 0x5E5_0C3E)
        var records: [Record] = []
        var resources: [ResourceKind: [Point]] = [:]

        for session in sessions {
            let roll = resourceRandom.double(in: 0...1)
            let kind: ResourceKind? = roll < 0.004 ? .cpu : roll < 0.006 ? .diskWrite : nil
            if let kind {
                let frames = kind == .cpu ? ["ImageCache.decodeAll()", "vImageConvert_ARGB8888toRGB888", "libdispatch.dylib"] : ["Library.save()", "sqlite3_step", "pwrite"]
                let name = kind == .cpu ? "CPU Exception" : "Disk Write Exception"
                records.append(
                    session.versioned(
                        ResourceException(
                            name: name,
                            fingerprint: "resource-\(kind.rawValue)",
                            reason: kind == .cpu ? "92 s of CPU time in 180 s" : "1024 MB written to disk",
                            stackTrace: frames,
                            resourceKind: kind,
                            date: session.end,
                            id: resourceRandom.uuid().uuidString,
                            deviceID: session.device.id,
                            installID: session.install.id,
                            launchID: session.launchID,
                            sessionID: session.id
                        )
                        .record
                    )
                )
                resources[kind, default: []].append(Point(date: session.end, version: session.version.version, installID: session.install.id))
            }
        }

        return (records, resources)
    }
}

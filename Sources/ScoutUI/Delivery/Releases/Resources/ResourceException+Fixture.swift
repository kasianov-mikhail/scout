//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

extension ResourceException: Fixture {
    static var sample: ResourceException {
        sample(kind: .cpu, at: Date())
    }

    static var samples: [ResourceException] {
        let now = Date()
        return [
            sample(kind: .cpu, at: now.addingTimeInterval(-3_600)),
            sample(kind: .cpu, at: now.addingTimeInterval(-86_400)),
            sample(kind: .diskWrite, at: now.addingTimeInterval(-2 * 86_400)),
        ]
    }

    static func sample(kind: ResourceKind, at date: Date, deviceID: UUID? = UUID(), sessionID: UUID? = UUID()) -> ResourceException {
        let name = kind == .cpu ? "CPU Exception" : "Disk Write Exception"
        let stackTrace = [
            "0   CoreGraphics          0x0 CGSConvertBGRA8888toRGBA8888 + 276",
            "1   CoreGraphics          0x0 CGContextDrawImage + 420",
            "2   UIKitCore             0x0 -[UIGraphicsImageRenderer imageWithActions:] + 136",
            "3   MyApp                 0x0 ImageCache.resize(_:to:) + 88",
            "4   MyApp                 0x0 ImageCache.resizeAll(_:) + 60",
            "5   MyApp                 0x0 FeedPrefetcher.prefetch(_:) + 144",
            "6   libdispatch.dylib     0x0 _dispatch_call_block_and_release + 32",
            "7   libdispatch.dylib     0x0 _dispatch_client_callout + 20",
            "8   libdispatch.dylib     0x0 _dispatch_lane_serial_drain + 748",
            "9   libdispatch.dylib     0x0 _dispatch_lane_invoke + 380",
            "10  libdispatch.dylib     0x0 _dispatch_root_queue_drain_deferred_wlh + 288",
            "11  libdispatch.dylib     0x0 _dispatch_workloop_worker_thread + 540",
            "12  libsystem_pthread.dylib 0x0 start_wqthread + 8",
        ]

        return ResourceException(
            name: name,
            fingerprint: CrashFingerprint(name: name, reason: nil, stackTrace: stackTrace).value,
            reason: kind == .cpu ? "92 s of CPU time in 180 s" : "1024 MB written to disk",
            stackTrace: stackTrace,
            resourceKind: kind,
            date: date,
            id: UUID().uuidString,
            deviceID: deviceID,
            installID: UUID(),
            launchID: UUID(),
            sessionID: sessionID
        )
    }

    static var sampleGroup: IncidentGroup<ResourceException> {
        let devices = (0..<3).map { _ in UUID() }
        let resources = (0..<4).map { index in
            sample(kind: .cpu, at: Date(), deviceID: devices[index % devices.count])
        }
        return IncidentGroup(id: resources[0].fingerprint, records: resources, symbol: nil)
    }
}

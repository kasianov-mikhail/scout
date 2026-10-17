//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct MetricKitCrash: MetricKitIncident, Sendable {
    let exceptionType: Int?
    let signal: Int32?
    let terminationReason: String?
    let exception: Exception?
    let appVersion: String?
    let processID: Int32?
    let window: DateInterval
    let frames: [MetricKitStackTree.Frame]

    struct Exception: Sendable {
        let name: String
        let message: String
    }
}

private let machExceptionNames: [Int: String] = [
    1: "EXC_BAD_ACCESS",
    2: "EXC_BAD_INSTRUCTION",
    3: "EXC_ARITHMETIC",
    4: "EXC_EMULATION",
    5: "EXC_SOFTWARE",
    6: "EXC_BREAKPOINT",
    7: "EXC_SYSCALL",
    8: "EXC_MACH_SYSCALL",
    9: "EXC_RPC_ALERT",
    10: "EXC_CRASH",
    11: "EXC_RESOURCE",
    12: "EXC_GUARD",
    13: "EXC_CORPSE_NOTIFY",
]

private let watchdogCode = "0x8badf00d"

extension MetricKitCrash {
    var name: String {
        if let exception {
            exception.name
        } else if terminationReason?.contains(watchdogCode) == true {
            "Watchdog Termination"
        } else if let exceptionType, let name = machExceptionNames[exceptionType] {
            name
        } else if let signal {
            signalName(signal)
        } else {
            "Unknown Crash"
        }
    }

    var reason: String? {
        exception?.message ?? terminationReason ?? signal.map(signalReason)
    }

    var isCaughtInProcess: Bool {
        exception != nil || fatalSignals.contains { $0.signal == signal }
    }

    var id: UUID {
        UUID(
            digesting: [
                name,
                reason ?? "",
                appVersion ?? "",
                processID.map(String.init) ?? "",
                String(window.start.timeIntervalSince1970),
                String(window.end.timeIntervalSince1970),
            ] + stackTrace
        )
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

private nonisolated(unsafe) var previousSignalHandlers: [Int32: sig_t] = [:]

private let signals: [Int32] = [
    SIGABRT,
    SIGSEGV,
    SIGBUS,
    SIGFPE,
    SIGILL,
    SIGTRAP,
]

/// Installs handlers for fatal signals (SIGABRT, SIGSEGV, SIGBUS, SIGFPE, SIGILL, SIGTRAP).
func installSignalHandler() {
    for sig in signals {
        previousSignalHandlers[sig] = signal(sig) { sig in
            let crash = CrashInfo(
                name: signalName(sig),
                reason: "Signal \(sig) received",
                stackTrace: Thread.callStackSymbols
            )
            CrashArchive.system.write(crash)

            let handler = previousSignalHandlers[sig] ?? SIG_DFL
            signal(sig, handler)
            raise(sig)
        }
    }
}

private func signalName(_ sig: Int32) -> String {
    switch sig {
    case SIGABRT:
        "SIGABRT"
    case SIGSEGV:
        "SIGSEGV"
    case SIGBUS:
        "SIGBUS"
    case SIGFPE:
        "SIGFPE"
    case SIGILL:
        "SIGILL"
    case SIGTRAP:
        "SIGTRAP"
    default:
        "SIGNAL_\(sig)"
    }
}

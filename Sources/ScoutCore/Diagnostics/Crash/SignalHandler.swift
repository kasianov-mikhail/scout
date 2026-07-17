//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

private nonisolated(unsafe) var previousSignalHandlers: [Int32: sig_t] = [:]
private nonisolated(unsafe) var isInstalled = false
private nonisolated(unsafe) var identity: Identity?

private let fatalSignals: [(signal: Int32, name: String)] = [
    (SIGABRT, "SIGABRT"),
    (SIGSEGV, "SIGSEGV"),
    (SIGBUS, "SIGBUS"),
    (SIGFPE, "SIGFPE"),
    (SIGILL, "SIGILL"),
    (SIGTRAP, "SIGTRAP"),
]

func installSignalHandler(identity: Identity) {
    guard !isInstalled else { return }
    isInstalled = true

    ScoutCore.identity = identity

    for (sig, _) in fatalSignals {
        previousSignalHandlers[sig] = signal(sig) { sig in
            if let identity = ScoutCore.identity {
                let crash = CrashInfo(
                    name: signalName(sig),
                    reason: "Signal \(sig) received",
                    stackTrace: Thread.callStackSymbols,
                    identity: identity
                )
                CrashArchive.system.write(crash)
            }

            restorePreviousSignalHandler(sig)
            raise(sig)
        }
    }
}

func restorePreviousSignalHandler(_ sig: Int32) {
    signal(sig, previousSignalHandlers[sig] ?? SIG_DFL)
}

private func signalName(_ sig: Int32) -> String {
    fatalSignals.first { $0.signal == sig }?.name ?? "SIGNAL_\(sig)"
}

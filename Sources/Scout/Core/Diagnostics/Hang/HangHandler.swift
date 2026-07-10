//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

private let watchdogQueue = DispatchQueue(label: "scout.hang.watchdog")

private nonisolated(unsafe) var isInstalled = false

// Touched only from closures scheduled on `watchdogQueue`, which is serial —
// that queue is the sole synchronization for these, not the `unsafe` opt-out.
private nonisolated(unsafe) var pingDate = Date()
private nonisolated(unsafe) var reportedWarning = false
private nonisolated(unsafe) var reportedCritical = false

private let pingInterval: TimeInterval = 1

// In the spirit of MetricKit's hang buckets: a first report once the main
// thread has been unresponsive for 3s, and a more severe one at 8s — around
// where the system watchdog would otherwise kill the app.
private let warningThreshold: TimeInterval = 3
private let criticalThreshold: TimeInterval = 8

/// Installs a watchdog that detects an unresponsive main thread and
/// captures its stack trace before the system watchdog can kill the app.
func installHangHandler(identity: Identity) {
    guard !isInstalled else { return }
    isInstalled = true

    schedulePing()
    scheduleCheck(identity: identity)
}

private func schedulePing() {
    DispatchQueue.main.async {
        watchdogQueue.async {
            pingDate = Date()
            reportedWarning = false
            reportedCritical = false
        }
        watchdogQueue.asyncAfter(deadline: .now() + pingInterval) {
            schedulePing()
        }
    }
}

private func scheduleCheck(identity: Identity) {
    watchdogQueue.asyncAfter(deadline: .now() + pingInterval) {
        checkForHang(identity: identity)
        scheduleCheck(identity: identity)
    }
}

private func checkForHang(identity: Identity) {
    let elapsed = Date().timeIntervalSince(pingDate)

    if elapsed >= criticalThreshold, !reportedCritical {
        reportedCritical = true
        reportHang(duration: elapsed, identity: identity)
    } else if elapsed >= warningThreshold, !reportedWarning {
        reportedWarning = true
        reportHang(duration: elapsed, identity: identity)
    }
}

private func reportHang(duration: TimeInterval, identity: Identity) {
    let hang = HangInfo(
        name: duration >= criticalThreshold ? "Watchdog Termination Imminent" : "Main Thread Blocked",
        reason: "Main thread unresponsive for \(String(format: "%.1f", duration))s",
        stackTrace: MainThreadBacktrace.capture(),
        duration: duration,
        identity: identity
    )
    HangArchive.system.write(hang)
}

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
// that queue is the sole synchronization for this, not the `unsafe` opt-out.
private nonisolated(unsafe) var monitor = HangMonitor(now: uptime)

// Wall-clock time counts a backgrounded process and a corrected clock as time
// the main thread spent unresponsive; uptime stops while the device sleeps and
// never jumps.
private var uptime: TimeInterval {
    ProcessInfo.processInfo.systemUptime
}

// Installs a watchdog that detects an unresponsive main thread and captures
// its stack trace before the system watchdog can kill the app.
func installHangHandler(identity: Identity) {
    guard !isInstalled else { return }
    isInstalled = true

    schedulePing()
    scheduleCheck(identity: identity)
}

private func schedulePing() {
    DispatchQueue.main.async {
        watchdogQueue.async {
            monitor.ping(at: uptime)
        }
        watchdogQueue.asyncAfter(deadline: .now() + HangMonitor.pingInterval) {
            schedulePing()
        }
    }
}

private func scheduleCheck(identity: Identity) {
    watchdogQueue.asyncAfter(deadline: .now() + HangMonitor.pingInterval) {
        if let duration = monitor.check(at: uptime) {
            reportHang(duration: duration, identity: identity)
        }
        scheduleCheck(identity: identity)
    }
}

private func reportHang(duration: TimeInterval, identity: Identity) {
    let isCritical = duration >= HangMonitor.criticalThreshold

    let hang = HangInfo(
        name: isCritical ? "Watchdog Termination Imminent" : "Main Thread Blocked",
        reason: "Main thread unresponsive for \(String(format: "%.1f", duration))s",
        stackTrace: MainThreadBacktrace.capture(),
        duration: duration,
        identity: identity
    )
    HangArchive.system.write(hang)
}

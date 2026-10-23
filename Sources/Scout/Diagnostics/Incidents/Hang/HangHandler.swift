//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

private let watchdogQueue = DispatchQueue(label: "scout.hang.watchdog")

private nonisolated(unsafe) var isInstalled = false

private nonisolated(unsafe) var monitor = HangMonitor(now: uptime)

private var uptime: TimeInterval {
    ProcessInfo.processInfo.systemUptime
}

extension Identity {
    func installHangHandler() {
        guard !isInstalled else { return }
        isInstalled = true

        schedulePing()
        scheduleHangCheck()
    }

    fileprivate func scheduleHangCheck() {
        watchdogQueue.asyncAfter(deadline: .now() + HangMonitor.pingInterval) {
            if let duration = monitor.check(at: uptime) {
                reportHang(duration: duration)
            }
            scheduleHangCheck()
        }
    }

    fileprivate func reportHang(duration: TimeInterval) {
        let isCritical = duration >= HangMonitor.criticalThreshold
        let addresses = MainThreadBacktrace.capture()

        let hang = HangInfo(
            name: isCritical ? "Watchdog Termination Imminent" : "Main Thread Blocked",
            reason: "Main thread unresponsive for \(String(format: "%.1f", duration))s",
            stackTrace: addresses.enumerated().map(StackWalker.symbolicate),
            backtrace: Backtrace(addresses: addresses, images: LoadedImage.loaded()),
            duration: duration,
            identity: self
        )
        IncidentArchive.hang.write(hang)
    }
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

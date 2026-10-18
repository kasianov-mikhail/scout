//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("MetricKitCrash")
struct MetricKitCrashTests {
    private let window = DateInterval(start: Date(timeIntervalSince1970: 1_750_000_000), duration: 600)

    @Test("An Objective-C exception names the crash and gives its reason")
    func objectiveCException() throws {
        let crash = try makeCrash(
            exceptionType: 10,
            signal: 6,
            exception: MetricKitCrash.Exception(name: "NSRangeException", message: "index 4 beyond bounds [0 .. 2]")
        )

        #expect(crash.name == "NSRangeException")
        #expect(crash.reason == "index 4 beyond bounds [0 .. 2]")
    }

    @Test("A watchdog kill reads as a watchdog termination with the system's reason")
    func watchdog() throws {
        let reason = "Namespace FRONTBOARD, Code 0x8badf00d"
        let crash = try makeCrash(exceptionType: 10, signal: 9, terminationReason: reason)

        #expect(crash.name == "Watchdog Termination")
        #expect(crash.reason == reason)
    }

    @Test("A Mach exception names the crash and the signal gives its reason")
    func machException() throws {
        let crash = try makeCrash(exceptionType: 1, signal: 11)

        #expect(crash.name == "EXC_BAD_ACCESS")
        #expect(crash.reason == "Signal 11 received")
    }

    @Test("An unknown exception type falls back to the signal's name")
    func signalFallback() throws {
        let crash = try makeCrash(exceptionType: 99, signal: 11)

        #expect(crash.name == "SIGSEGV")
    }

    @Test("A crash with nothing to name it reads as unknown")
    func unknownCrash() throws {
        let crash = try makeCrash()

        #expect(crash.name == "Unknown Crash")
        #expect(crash.reason == nil)
    }

    @Test("The stack trace lists the crashed thread's binaries and offsets")
    func stackTrace() throws {
        let crash = try makeCrash(exceptionType: 1, signal: 11)

        #expect(crash.stackTrace == ["0   MyApp   + 0x1a2f0", "1   UIKitCore   + 0x1388", "2   MyApp   + 0x7d0"])
    }

    @Test("The window ends at the crash date and starts the MetricKit source")
    func windowBounds() throws {
        let crash = try makeCrash(exceptionType: 1, signal: 11)

        #expect(crash.date == window.end)
        #expect(crash.source == .metricKit(windowStart: window.start))
    }

    @Test("A window with no length carries no start")
    func instantWindow() throws {
        let crash = try makeCrash(exceptionType: 1, signal: 11, window: DateInterval(start: window.end, duration: 0))

        #expect(crash.source == .metricKit(windowStart: nil))
    }

    @Test("Crashes at the same offsets share a fingerprint whatever their reason or time")
    func fingerprintIgnoresReasonAndTime() throws {
        let first = try makeCrash(exceptionType: 10, signal: 9, terminationReason: "Namespace FRONTBOARD, Code 0x8badf00d, 10.00 s")
        let second = try makeCrash(
            exceptionType: 10,
            signal: 9,
            terminationReason: "Namespace FRONTBOARD, Code 0x8badf00d, 20.00 s",
            window: DateInterval(start: window.end, duration: 60)
        )

        #expect(first.fingerprint == second.fingerprint)
    }

    @Test("Crashes at different offsets in one binary get different fingerprints")
    func fingerprintKeepsOffsets() throws {
        let json = crashTreeJSON.replacingOccurrences(of: "107248", with: "107252")
        let first = try makeCrash(exceptionType: 1, signal: 11)
        let second = try makeCrash(exceptionType: 1, signal: 11, json: json)

        #expect(first.fingerprint != second.fingerprint)
    }

    @Test("The same report always gets the same id")
    func stableID() throws {
        #expect(try makeCrash(exceptionType: 1, signal: 11).id == makeCrash(exceptionType: 1, signal: 11).id)
    }

    @Test("Reports from different windows get different ids")
    func distinctIDs() throws {
        let first = try makeCrash(exceptionType: 1, signal: 11)
        let second = try makeCrash(exceptionType: 1, signal: 11, window: DateInterval(start: window.end, duration: 600))

        #expect(first.id != second.id)
    }

    private func makeCrash(exceptionType: Int? = nil, signal: Int32? = nil, terminationReason: String? = nil, exception: MetricKitCrash.Exception? = nil, window: DateInterval? = nil, json: String = crashTreeJSON) throws -> MetricKitCrash {
        let tree = try MetricKitStackTree(json: Data(json.utf8))
        return MetricKitCrash(
            exceptionType: exceptionType,
            signal: signal,
            terminationReason: terminationReason,
            exception: exception,
            appVersion: "3.2.0",
            processID: 412,
            window: window ?? self.window,
            frames: tree.crashedFrames,
            threads: tree.threads,
            backtrace: tree.backtrace
        )
    }
}

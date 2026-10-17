//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

@Suite("ExitReason")
struct ExitReasonTests {
    @Test("Only normal exits and memory pressure exits are clean")
    func cleanReasons() {
        #expect(ExitReason.allCases.filter(\.isClean) == [.normal, .memoryPressure])
    }

    @Test("Raw values match the categories the server groups by")
    func rawValues() {
        #expect(
            ExitReason.allCases.map(\.rawValue) == [
                "normal", "memory_pressure", "memory_limit", "cpu_limit", "watchdog",
                "bad_access", "illegal_instruction", "abnormal", "locked_file", "task_timeout",
            ])
    }
}

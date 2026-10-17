//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

package enum ExitReason: String, CaseIterable, Sendable {
    case normal
    case memoryPressure = "memory_pressure"
    case memoryLimit = "memory_limit"
    case cpuLimit = "cpu_limit"
    case watchdog
    case badAccess = "bad_access"
    case illegalInstruction = "illegal_instruction"
    case abnormal
    case lockedFile = "locked_file"
    case taskTimeout = "task_timeout"
}

extension ExitReason {
    package var isClean: Bool {
        switch self {
        case .normal, .memoryPressure:
            true
        case .memoryLimit, .cpuLimit, .watchdog, .badAccess, .illegalInstruction, .abnormal, .lockedFile, .taskTimeout:
            false
        }
    }
}

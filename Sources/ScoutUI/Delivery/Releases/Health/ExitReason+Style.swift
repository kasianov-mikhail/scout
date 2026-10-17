//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension ExitReason {
    var title: String {
        switch self {
        case .normal:
            "Normal"
        case .memoryPressure:
            "Memory pressure"
        case .memoryLimit:
            "Memory limit"
        case .cpuLimit:
            "CPU limit"
        case .watchdog:
            "Watchdog"
        case .badAccess:
            "Bad access"
        case .illegalInstruction:
            "Illegal instruction"
        case .abnormal:
            "Abnormal"
        case .lockedFile:
            "Locked file"
        case .taskTimeout:
            "Task timeout"
        }
    }

    var color: Color {
        switch self {
        case .normal:
            .gray
        case .memoryPressure, .memoryLimit:
            .purple
        case .cpuLimit:
            .yellow
        case .watchdog:
            IncidentKind.hang.color
        case .badAccess, .illegalInstruction, .abnormal:
            IncidentKind.crash.color
        case .lockedFile, .taskTimeout:
            .teal
        }
    }
}

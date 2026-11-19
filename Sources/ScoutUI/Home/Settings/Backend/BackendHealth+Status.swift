//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

extension Backend.Engine {
    var label: String {
        switch self {
        case .cloudKit:
            "CloudKit"
        case .server:
            "Scout Server"
        case .local:
            "On Device"
        }
    }
}

extension Backend.Status? {
    var healthLabel: String {
        switch self {
        case .reachable:
            "Operational"
        case .readOnly:
            "Read-Only"
        case .unreachable:
            "Unreachable"
        case nil:
            "Checking"
        }
    }

    var healthColor: Color {
        switch self {
        case .reachable:
            .fillSuccess
        case .readOnly:
            .fillWarning
        case .unreachable:
            .fillDanger
        case nil:
            .textMuted
        }
    }
}

extension BackendHealth {
    var detailLabel: String? {
        switch status {
        case .unreachable:
            "no answer"
        case .readOnly:
            "read only"
        case .reachable:
            engine.label
        case nil:
            probe == nil ? engine.label : nil
        }
    }

    var segmentState: SettingsSegmentState {
        switch status {
        case .unreachable, .readOnly:
            .error
        case .reachable:
            .normal
        case nil:
            probe == nil ? .normal : .loading
        }
    }

    var isCloud: Bool {
        if case .cloudKit = engine {
            true
        } else {
            false
        }
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

extension Hang: Incident {}

extension Hang {
    var severity: HangSeverity {
        duration >= 8 ? .critical : .warning
    }

    var durationText: String {
        duration < 60 ? String(format: "%.1fs", duration) : "\(Int(duration) / 60)m \(Int(duration) % 60)s"
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct HangExport {
    let hang: Hang

    var text: String {
        IncidentExport(
            incident: hang,
            kind: "Hang",
            detail: [.blank, .text("Duration: \(hang.durationText)")]
        ).text
    }
}

struct HangGroupExport {
    let group: IncidentGroup<Hang>

    var text: String {
        IncidentGroupExport(
            group: group,
            kind: "Hang",
            summaryDetail: [.blank, .text("Max duration: \(group.durationText)")],
            rowSuffix: { "  \($0.durationText)" }
        ).text
    }
}

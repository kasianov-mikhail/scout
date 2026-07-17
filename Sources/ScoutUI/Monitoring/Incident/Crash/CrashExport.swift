//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

struct CrashExport {
    let crash: Crash

    var text: String {
        IncidentExport(incident: crash, kind: "Crash", detail: []).text
    }
}

struct CrashGroupExport {
    let group: IncidentGroup<Crash>

    var text: String {
        let summaryDetail = group.representative.reason.map { [ExportLine.blank, .text("Reason: \($0)")] } ?? []
        return IncidentGroupExport(
            group: group,
            kind: "Crash",
            summaryDetail: summaryDetail,
            rowSuffix: { _ in "" }
        ).text
    }
}

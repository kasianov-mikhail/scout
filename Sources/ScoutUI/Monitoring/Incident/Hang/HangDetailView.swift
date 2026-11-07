//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct HangDetailView: View {
    let hang: Hang
    let group: IncidentGroup<Hang>?
    let backtrace: BacktraceProvider?
    let context: IncidentContextProvider?

    init(hang: Hang, group: IncidentGroup<Hang>? = nil, backtrace: BacktraceProvider? = nil, context: IncidentContextProvider? = nil) {
        self.hang = hang
        self.group = group
        self.backtrace = backtrace
        self.context = context
    }

    var body: some View {
        IncidentDetailView(element: hang, group: group, backtrace: backtrace, context: context)
            .exportToolbar(text: HangExport(hang: hang).text)
    }
}

#Preview("Hang") {
    NavigationStack {
        HangDetailView(
            hang: .sample,
            group: Hang.sampleGroup,
            backtrace: BacktraceProvider(.success(.hangSample), incidentID: ""),
            context: IncidentContextProvider(.success(.sample), sessionID: nil, deviceID: nil)
        )
    }
    .environmentObject(Tint())
}

#Preview("Hang loading") {
    NavigationStack {
        HangDetailView(hang: .sample, group: Hang.sampleGroup)
    }
    .environmentObject(Tint())
}

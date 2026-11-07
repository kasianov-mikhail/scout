//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct CrashDetailView: View {
    let crash: Crash
    let group: IncidentGroup<Crash>?
    let backtrace: BacktraceProvider?
    let context: IncidentContextProvider?

    init(crash: Crash, group: IncidentGroup<Crash>? = nil, backtrace: BacktraceProvider? = nil, context: IncidentContextProvider? = nil) {
        self.crash = crash
        self.group = group
        self.backtrace = backtrace
        self.context = context
    }

    var body: some View {
        IncidentDetailView(element: crash, group: group, backtrace: backtrace, context: context)
            .exportToolbar(text: CrashExport(crash: crash).text)
    }
}

#Preview("Crash") {
    NavigationStack {
        CrashDetailView(
            crash: .sample,
            group: Crash.sampleGroup,
            backtrace: BacktraceProvider(.success(.sample), incidentID: ""),
            context: IncidentContextProvider(.success(.sample), sessionID: nil, deviceID: nil)
        )
    }
    .environmentObject(Tint())
}

#Preview("Crash loading") {
    NavigationStack {
        CrashDetailView(crash: .sample, group: Crash.sampleGroup)
    }
    .environmentObject(Tint())
}

#Preview("MetricKit") {
    NavigationStack {
        CrashDetailView(
            crash: .sample(source: .metricKit(windowStart: Date(timeIntervalSinceNow: -720))),
            group: Crash.sampleGroup,
            backtrace: BacktraceProvider(.success(.sample), incidentID: ""),
            context: IncidentContextProvider(.success(.sample), sessionID: nil, deviceID: nil)
        )
    }
    .environmentObject(Tint())
}

#Preview("MetricKit Without Window") {
    NavigationStack {
        CrashDetailView(
            crash: .sample(source: .metricKit(windowStart: nil)),
            group: Crash.sampleGroup,
            backtrace: BacktraceProvider(.success(.sample), incidentID: ""),
            context: IncidentContextProvider(.success(.sample), sessionID: nil, deviceID: nil)
        )
    }
    .environmentObject(Tint())
}

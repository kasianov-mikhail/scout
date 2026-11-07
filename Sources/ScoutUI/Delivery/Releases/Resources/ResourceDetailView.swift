//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct ResourceDetailView: View {
    let resource: ResourceException
    let group: IncidentGroup<ResourceException>?
    let backtrace: BacktraceProvider?
    let context: IncidentContextProvider?

    init(resource: ResourceException, group: IncidentGroup<ResourceException>? = nil, backtrace: BacktraceProvider? = nil, context: IncidentContextProvider? = nil) {
        self.resource = resource
        self.group = group
        self.backtrace = backtrace
        self.context = context
    }

    var body: some View {
        IncidentDetailView(element: resource, group: group, backtrace: backtrace, context: context)
    }
}

#Preview("Resource") {
    NavigationStack {
        ResourceDetailView(
            resource: .sample,
            group: ResourceException.sampleGroup,
            backtrace: BacktraceProvider(.success(.resourceSample), incidentID: ""),
            context: IncidentContextProvider(.success(.sample), sessionID: nil, deviceID: nil)
        )
    }
    .environmentObject(Tint())
}

#Preview("Resource loading") {
    NavigationStack {
        ResourceDetailView(resource: .sample, group: ResourceException.sampleGroup)
    }
    .environmentObject(Tint())
}

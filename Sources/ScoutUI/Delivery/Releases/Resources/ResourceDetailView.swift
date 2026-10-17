//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ResourceDetailView: View {
    let resource: ResourceException

    var body: some View {
        InsetList {
            VStack(alignment: .leading, spacing: 0) {
                if let date = resource.date {
                    UTCTimestampText(date: date)
                        .frame(height: 44)
                }

                if let reason = resource.reason {
                    Text(verbatim: reason)
                        .fontWeight(.bold)
                        .foregroundStyle(IncidentKind.resource.color)
                }
            }
            .listRowSeparator(.hidden, edges: .top)
            .padding(.bottom)

            ContextSection(context: resource, timelineHighlight: IncidentKind.resource.color)
            StackTraceSection(frames: resource.stackTrace, caption: nil)
        }
        .navigationTint(IncidentKind.resource.color)
        .monospacedNavigationTitle(en: resource.name)
    }
}

#Preview {
    NavigationStack {
        ResourceDetailView(resource: .sample)
    }
    .environmentObject(Tint())
}

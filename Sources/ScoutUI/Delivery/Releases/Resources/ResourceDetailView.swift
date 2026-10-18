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

    @StateObject private var provider: BacktraceProvider
    @Environment(\.database) private var database

    init(resource: ResourceException, provider: BacktraceProvider? = nil) {
        self.resource = resource
        self._provider = StateObject(wrappedValue: provider ?? BacktraceProvider(incidentID: resource.id))
    }

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

            ContextSection(
                context: resource,
                timelineHighlight: IncidentKind.resource.color
            )
            StackTraceSection(
                frames: resource.stackTrace,
                caption: "Unsymbolicated",
                detail: provider.detail
            )
            if let detail = provider.detail {
                BinaryImagesSection(images: detail.backtrace.images)
            }
        }
        .navigationTint(IncidentKind.resource.color)
        .monospacedNavigationTitle(en: resource.name)
        .task {
            await provider.fetchIfNeeded(in: database)
        }
    }
}

#Preview {
    NavigationStack {
        ResourceDetailView(
            resource: .sample,
            provider: BacktraceProvider(.success(.sample), incidentID: "")
        )
    }
    .environmentObject(Tint())
}

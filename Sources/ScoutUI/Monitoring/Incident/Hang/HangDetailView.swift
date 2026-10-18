//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HangDetailView: View {
    let hang: Hang

    @StateObject private var provider: BacktraceProvider
    @Environment(\.database) private var database

    init(hang: Hang, provider: BacktraceProvider? = nil) {
        self.hang = hang
        self._provider = StateObject(wrappedValue: provider ?? BacktraceProvider(incidentID: hang.id))
    }

    var body: some View {
        InsetList {
            VStack(alignment: .leading, spacing: 0) {
                if let date = hang.date {
                    UTCTimestampText(date: date)
                        .frame(height: 44)
                }

                HStack(spacing: 6) {
                    Image(systemName: hang.severity.systemImage)
                        .foregroundStyle(IncidentKind.hang.color)
                    Text(verbatim: "\(hang.severity.label) · \(hang.duration.duration)")
                        .fontWeight(.bold)
                        .foregroundStyle(IncidentKind.hang.color)
                }
                Divider().padding(.vertical)
                if let reason = hang.reason {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(verbatim: "BLOCKED ON:")
                        Text(reason)
                            .foregroundStyle(IncidentKind.hang.color)
                    }
                    .fontWeight(.bold)
                }
            }
            .listRowSeparator(.hidden, edges: .top)
            .padding(.bottom)

            ContextSection(
                context: hang,
                timelineHighlight: IncidentKind.hang.color
            )
            StackTraceSection(
                frames: hang.stackTrace,
                caption: nil
            )
            if case .success(let backtrace?) = provider.result {
                BinaryImagesSection(images: backtrace.images)
            }
        }
        .navigationTint(IncidentKind.hang.color)
        .exportToolbar(text: HangExport(hang: hang).text)
        .monospacedNavigationTitle(en: hang.name)
        .task {
            await provider.fetchIfNeeded(in: database)
        }
    }
}

#Preview {
    NavigationStack {
        HangDetailView(hang: .sample, provider: BacktraceProvider(.success(.sample), incidentID: ""))
    }
    .environmentObject(Tint())
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct CrashGroupDetailView: View {
    let group: CrashGroup

    var body: some View {
        List {
            headerSection

            Header(title: "Occurrences")

            ForEach(group.crashes) { crash in
                Row {
                    CrashOccurrenceRow(crash: crash)
                } destination: {
                    CrashDetailView(crash: crash)
                }
            }

            if !group.stackTrace.isEmpty {
                stackTraceSection
            }
        }
        .listStyle(.plain)
        .toolbarBackground(Color.red.opacity(0.12), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationTitle(en: group.name)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let reason = group.reason {
                Text(reason)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.red)
            }

            HStack(spacing: 24) {
                CrashGroupMetric(title: "Crashes", value: "\(group.count)")
                CrashGroupMetric(title: "Sessions", value: "\(group.affectedSessions)")

                if let firstDate = group.firstDate {
                    CrashGroupMetric(title: "First", value: firstDate.relativeString)
                }

                if let lastDate = group.lastDate {
                    CrashGroupMetric(title: "Last", value: lastDate.relativeString)
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var stackTraceSection: some View {
        Header(title: "Stack Trace")

        ForEach(Array(group.stackTrace.enumerated()), id: \.offset) { _, frame in
            Text(frame)
                .font(.system(size: 12))
                .monospaced()
                .lineLimit(2)
        }
    }
}

#Preview {
    NavigationStack {
        CrashGroupDetailView(
            group: CrashGroup.groups(
                from: [
                    .sample(
                        name: "NSRangeException",
                        fingerprint: "range",
                        reason: "Index 7 beyond bounds [0 .. 5]",
                        stackTrace: [
                            "0 Scout CrashListView.row(for:)",
                            "1 SwiftUI ListCore.updateVisibleRows()",
                            "2 UIKitCore UIApplicationMain",
                        ],
                        date: Date().addingTimeInterval(-300),
                        sessionID: UUID()
                    ),
                    .sample(
                        name: "NSRangeException",
                        fingerprint: "range",
                        reason: "Index 7 beyond bounds [0 .. 5]",
                        stackTrace: [
                            "0 Scout CrashListView.row(for:)",
                            "1 SwiftUI ListCore.updateVisibleRows()",
                            "2 UIKitCore UIApplicationMain",
                        ],
                        date: Date().addingTimeInterval(-3600),
                        sessionID: UUID()
                    ),
                ]
            )[0]
        )
    }
    .environmentObject(Tint())
}

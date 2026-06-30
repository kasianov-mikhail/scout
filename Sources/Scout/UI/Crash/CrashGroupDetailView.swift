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
            occurrencesSection
        }
        .listStyle(.plain)
        .navigationTint(.red)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                let text = CrashGroupExport(group: group).text
                ShareLink(item: text)
                    .tint(Color.primary)
                CopyButton(text: text)
                    .tint(Color.primary)
                Spacer()
            }
        }
        .navigationTitle(group.name)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 24) {
                Metric(title: "Occurrences", value: "\(group.count)")
                Metric(title: "Devices", value: "\(group.affectedDevices)")
                Metric(title: "Sessions", value: "\(group.affectedSessions)")
            }

            if let reason = group.representative.reason {
                Text(verbatim: "REASON:   ").fontWeight(.bold)
                    + Text(reason).fontWeight(.bold).foregroundColor(.red)
            }

            if let first = group.firstDate, let last = group.lastDate {
                Text(verbatim: "First seen \(first.relativeString) · Last seen \(last.relativeString)")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var occurrencesSection: some View {
        Header(title: "Occurrences")

        ForEach(group.crashes) { crash in
            Row {
                if let date = crash.date {
                    Text(utcDateFormatter.string(from: date) + " UTC")
                        .font(.system(size: 14))
                        .monospaced()
                }

                Spacer()

                if let sessionID = crash.sessionID {
                    Text(sessionID.uuidString.prefix(8))
                        .font(.system(size: 13))
                        .monospaced()
                        .foregroundStyle(Color.gray)
                }
            } destination: {
                CrashDetailView(crash: crash)
            }
        }
    }

}

#Preview {
    NavigationStack {
        CrashGroupDetailView(
            group: CrashGroup(crashes: [
                .sample("NSRangeException", at: Date()),
                .sample("NSRangeException", at: Date().addingTimeInterval(-3600)),
            ])
        )
    }
    .environmentObject(Tint())
}

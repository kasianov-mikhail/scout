//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct CrashDetailView: View {
    let crash: Crash

    var body: some View {
        List {
            headerSection

            if !crash.stackTrace.isEmpty {
                stackTraceSection
            }
        }
        .listStyle(.plain)
        .navigationTint(.red)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                let text = CrashExport(crash: crash).text
                ShareLink(item: text)
                CopyButton(text: text)
                Spacer()
            }
        }
        .navigationTitle(crash.name)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let date = crash.date {
                UTCTimestampText(date: date)
            }

            if let reason = crash.reason {
                Text(verbatim: "REASON:   ").fontWeight(.bold)
                    + Text(reason).fontWeight(.bold).foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var stackTraceSection: some View {
        Header(title: "Stack Trace")

        ForEach(Array(crash.stackTrace.enumerated()), id: \.offset) { _, frame in
            Text(frame)
                .font(.fixedCaption)
                .monospaced()
                .lineLimit(2)
        }
    }
}

#Preview {
    NavigationStack {
        CrashDetailView(crash: .sample)
    }
    .environmentObject(Tint())
}

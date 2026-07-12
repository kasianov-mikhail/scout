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
            VStack(alignment: .leading, spacing: 10) {
                if let date = crash.date {
                    UTCTimestampText(date: date)
                }

                if let reason = crash.reason {
                    (Text(verbatim: "REASON:   ") + Text(reason).foregroundColor(.red))
                        .lineSpacing(4)
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical, 4)

            ContextSection(context: crash, timelineHighlight: .red)

            StackTraceSection(frames: crash.stackTrace)
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
        .monospacedNavigationTitle(en: crash.name)
    }
}

#Preview {
    NavigationStack {
        CrashDetailView(crash: .sample)
    }
    .environmentObject(Tint())
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HangDetailView: View {
    let hang: Hang

    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 10) {
                if let date = hang.date {
                    UTCTimestampText(date: date)
                }

                HStack(spacing: 6) {
                    Image(systemName: hang.severity.systemImage)
                        .foregroundStyle(hang.severity.color)
                    Text(verbatim: "\(hang.severity.label) · \(hang.durationText)")
                        .fontWeight(.bold)
                        .foregroundStyle(hang.severity.color)
                }

                if let reason = hang.reason {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(verbatim: "BLOCKED ON:")
                        Text(reason)
                            .foregroundColor(hang.severity.color)
                    }
                    .fontWeight(.bold)
                }
            }
            .padding(.vertical, 4)

            ContextSection(context: hang, timelineHighlight: hang.severity.color)

            StackTraceSection(frames: hang.stackTrace)
        }
        .listStyle(.plain)
        .navigationTint(hang.severity.color)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                let text = HangExport(hang: hang).text
                ShareLink(item: text)
                CopyButton(text: text)
                Spacer()
            }
        }
        .monospacedNavigationTitle(en: hang.name)
    }
}

#Preview {
    NavigationStack {
        HangDetailView(hang: .sample)
    }
    .environmentObject(Tint())
}

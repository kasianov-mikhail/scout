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

    var body: some View {
        PlainList {
            VStack(alignment: .leading, spacing: 0) {
                if let date = hang.date {
                    UTCTimestampText(date: date)
                        .frame(height: 44)
                }

                HStack(spacing: 6) {
                    Image(systemName: hang.severity.systemImage)
                        .foregroundStyle(hang.severity.color)
                    Text(verbatim: "\(hang.severity.label) · \(hang.duration.duration)")
                        .fontWeight(.bold)
                        .foregroundStyle(hang.severity.color)
                }
                Divider().padding(.vertical)
                if let reason = hang.reason {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(verbatim: "BLOCKED ON:")
                        Text(reason)
                            .foregroundColor(hang.severity.color)
                    }
                    .fontWeight(.bold)
                }
            }
            .listRowSeparator(.hidden, edges: .top)
            .padding(.bottom)

            ContextSection(context: hang, timelineHighlight: hang.severity.color)

            StackTraceSection(frames: hang.stackTrace)
        }
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

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct SegmentOccurrenceList<Element: Incident, RowContent: View>: View {
    let title: String
    let records: [Element]
    @ViewBuilder let row: (Element) -> RowContent

    var body: some View {
        List {
            ForEach(records, content: row)
        }
        .listStyle(.plain)
        .monospacedNavigationTitle(en: title)
    }
}

#Preview {
    NavigationStack {
        SegmentOccurrenceList(title: "iPhone15,3", records: [Crash].samples) { crash in
            Row {
                if let date = crash.date {
                    UTCTimestampText(date: date, size: 14)
                }
            } destination: {
                CrashDetailView(crash: crash)
            }
        }
    }
    .environmentObject(Tint())
}

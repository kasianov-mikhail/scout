//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SessionTimelineView: View {
    let timeline: SessionTimeline

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                SessionHeader(info: timeline.info)

                Section(title: "Events", insetsContent: false) {
                    Text(verbatim: "from session start")
                        .font(.scoutCaption)
                        .foregroundStyle(Color.timelineUnknown)
                } content: {
                    Color.clear.frame(height: 8)

                    ForEach(timeline.rows) { row in
                        SessionTimelineRowView(row: row)
                    }

                    Color.clear.frame(height: 8)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    NavigationStack {
        SessionTimelineView(timeline: .sample)
            .navigationTitle(en: "Session")
            .inlineNavigationTitle()
    }
}

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

                SessionEventsHeader()

                Color.clear.frame(height: 8)

                ForEach(timeline.rows) { row in
                    SessionTimelineRowView(row: row)
                }

                Color.clear.frame(height: 8)
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct SessionEventsHeader: View {
    var body: some View {
        HStack {
            Text(verbatim: "EVENTS")
                .font(.scoutSection)

            Spacer()

            Text(verbatim: "from session start")
                .font(.scoutCaption)
                .foregroundStyle(Color.timelineUnknown)
        }
        .padding(.top, .space12)
        .padding(.horizontal, .gutter)
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.lineSeparator)
                .frame(height: 0.5)
                .padding(.horizontal, .gutter)
        }
    }
}

#Preview {
    NavigationStack {
        SessionTimelineView(timeline: .sample)
            .navigationTitle(en: "Session")
            .inlineNavigationTitle()
    }
}

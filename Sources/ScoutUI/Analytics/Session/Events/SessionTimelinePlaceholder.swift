//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SessionTimelinePlaceholder: View {
    private let rows = SessionSkeletonRow.samples

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                summary
                chips
                SessionEventsHeader()

                Color.clear.frame(height: 8)

                ForEach(rows.indices, id: \.self) { index in
                    SessionSkeletonRowView(row: rows[index], delay: Double(index) * 0.08 + 0.24)
                }

                Color.clear.frame(height: 8)
            }
        }
        .scrollDisabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var summary: some View {
        HStack(spacing: 4) {
            SkeletonBar(width: 74, height: 9, delay: 0.08)
            SkeletonBar(width: 120, height: 9, delay: 0.08)
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 14)
        .padding(.horizontal, 16)
        .frame(height: 39)
        .overlay(alignment: .bottom) {
            divider
        }
    }

    private var chips: some View {
        FlowLayout(spacing: 6) {
            ForEach(SessionSkeletonChip.samples) { chip in
                SkeletonBar(width: chip.width, height: 9, delay: 0.16)
                    .padding(.horizontal, 9)
                    .frame(height: 26)
                    .overlay {
                        Capsule().stroke(Color.timelineTrack, lineWidth: 0.5)
                    }
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            divider
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(.systemGray3))
            .frame(height: 0.5)
            .padding(.horizontal, 16)
    }
}

#Preview {
    NavigationStack {
        SessionTimelinePlaceholder()
            .navigationTitle(en: "Session")
            .inlineNavigationTitle()
    }
}

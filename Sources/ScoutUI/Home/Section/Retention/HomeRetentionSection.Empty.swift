//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

extension HomeRetentionSection {
    struct Empty: View {
        let now: Date

        var body: some View {
            Section(title: "Retention", note: "kept on day 7", bottomGap: .space10) {
                ForEach(Array(starts.enumerated()), id: \.element) { index, start in
                    row(start: start, fraction: fractions[index], showsDivider: index < fractions.count - 1)
                }

                Text(verbatim: "Needs one full week of installs")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
                    .padding(.top, .space10)
                    .padding(.bottom, .space6)
            }
        }

        private func row(start: Date, fraction: CGFloat, showsDivider: Bool) -> some View {
            HStack(spacing: .space10) {
                Text(verbatim: DateFormatter.monthDay.string(from: start))
                    .font(.scoutRow)
                    .frame(width: 60, alignment: .leading)

                GeometryReader { proxy in
                    EmptyBar(width: proxy.size.width * fraction, height: 18, cornerRadius: .radiusBar)
                }
                .frame(height: 18)
                .frame(maxWidth: .infinity)

                EmptyBar(width: 48, height: 10)
                    .frame(width: 70, alignment: .trailing)
            }
            .frame(height: 40)
            .overlay(alignment: .bottom) {
                if showsDivider {
                    Separator.dashed
                }
            }
        }

        private var starts: [Date] {
            (1...fractions.count).map { now.startOfWeek.addingWeek(-$0) }
        }

        private let fractions: [CGFloat] = [0.8, 0.7, 0.76, 0.6]
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeRetentionSection.Empty(now: HomeSnapshot.date)
            }
        }
        .scrollIndicators(.hidden)
    }
}

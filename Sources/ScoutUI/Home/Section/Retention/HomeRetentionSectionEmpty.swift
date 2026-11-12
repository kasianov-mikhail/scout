//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

struct HomeRetentionSectionEmpty: View {
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HomeRetentionHeader()

            ForEach(Array(starts.enumerated()), id: \.element) { index, start in
                row(start: start, fraction: fractions[index])
            }

            Text(verbatim: "Needs one full week of installs")
                .font(.scoutCaption)
                .foregroundStyle(Color.textMuted)
                .padding(.top, .space10)
                .padding(.bottom, .space6)
        }
    }

    private func row(start: Date, fraction: CGFloat) -> some View {
        HStack(spacing: .space10) {
            Text(verbatim: DateFormatter.monthDay.string(from: start))
                .font(.scoutRow)
                .frame(width: 56, alignment: .leading)

            GeometryReader { proxy in
                EmptyBar(width: proxy.size.width * fraction, height: 18, cornerRadius: .radiusBar)
            }
            .frame(height: 18)
            .frame(maxWidth: .infinity)

            EmptyBar(width: 48, height: 10)
                .frame(width: 84, alignment: .trailing)
        }
        .frame(height: 40)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }

    private var starts: [Date] {
        (1...fractions.count).map { now.startOfWeek.addingWeek(-$0) }
    }

    private let fractions: [CGFloat] = [0.8, 0.7, 0.76, 0.6]
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeRetentionSectionEmpty(now: HomeSnapshot.date)
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}

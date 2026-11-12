//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReleaseHero: View {
    let detail: ReleaseDetail

    var body: some View {
        HStack(spacing: .space16) {
            VStack(alignment: .leading, spacing: .space6) {
                Text(verbatim: detail.release.id)
                    .font(.scoutNumberXL)
                    .tracking(-0.5)

                Text(verbatim: detail.statusLabel)
                    .font(.scoutRow)
                    .foregroundStyle(level.labelColor)

                Text(verbatim: detail.subtitle)
                    .font(.scoutRow)
                    .foregroundStyle(Color.textMuted)
            }

            Spacer(minLength: 0)

            badge
        }
        .padding(.top, .space12)
        .padding(.horizontal, .gutter)
        .padding(.bottom, .space16)
        .background(level.background)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(level.border)
                .frame(height: 0.5)
        }
    }

    private var level: Stability.Level {
        detail.release.freeSessions.level
    }

    private var badge: some View {
        VStack(spacing: .space2) {
            Text(verbatim: "SHIPPED")
                .font(.system(size: 10, weight: .bold))
                .tracking(1)

            Text(verbatim: detail.release.shipped.map { DateFormatter.monthDay.string(from: $0).uppercased() } ?? "—")
                .font(.scoutValueStrong)
        }
        .foregroundStyle(level.labelColor)
        .frame(width: 76, height: 76)
        .overlay {
            Circle()
                .strokeBorder(level.labelColor, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
        }
        .rotationEffect(.degrees(-12))
        .accessibilityHidden(true)
    }
}

#Preview {
    let release = [ReleaseHealth].samples[0]

    ReleaseHero(detail: ReleaseDetail(release: release, trend: .sample, now: Date()))
}

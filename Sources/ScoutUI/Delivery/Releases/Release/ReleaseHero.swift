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
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: detail.release.id)
                    .font(.system(size: 34, weight: .bold, design: .monospaced))
                    .tracking(-0.5)

                Text(verbatim: detail.statusLabel)
                    .font(.system(size: 15))
                    .foregroundStyle(level.tint)

                Text(verbatim: detail.subtitle)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(.systemGray))
            }

            Spacer(minLength: 0)

            badge
        }
        .padding(.top, 14)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
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
        VStack(spacing: 1) {
            Text(verbatim: "SHIPPED")
                .font(.system(size: 10, weight: .bold))
                .tracking(1)

            Text(verbatim: DateFormatter.monthDay.string(from: detail.release.released).uppercased())
                .font(.system(size: 13, weight: .bold, design: .monospaced))
        }
        .foregroundStyle(level.tint)
        .frame(width: 76, height: 76)
        .overlay {
            Circle()
                .strokeBorder(level.tint, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
        }
        .rotationEffect(.degrees(-12))
        .accessibilityHidden(true)
    }
}

#Preview {
    let release = [ReleaseHealth].samples[0]

    ReleaseHero(detail: ReleaseDetail(release: release, trend: .sample, now: Date()))
}

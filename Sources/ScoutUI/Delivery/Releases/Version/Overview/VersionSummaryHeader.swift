//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct VersionSummaryHeader: View {
    let summary: VersionSummary

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: summary.release.id)
                    .font(.system(size: 34, weight: .bold, design: .monospaced))
                    .tracking(-0.5)

                Text(verbatim: summary.statusLine)
                    .font(.system(size: 15))
                    .foregroundStyle(summary.level.accent)

                Text(verbatim: summary.adoptionLine)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(.systemGray))
            }

            Spacer(minLength: 0)

            stamp
        }
        .padding(EdgeInsets(top: 14, leading: 16, bottom: 16, trailing: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(summary.level.surface)
        .overlay(alignment: .bottom) {
            summary.level.edge
                .frame(height: 0.5)
        }
    }

    private var stamp: some View {
        VStack(spacing: 0) {
            Text(verbatim: "SHIPPED")
                .font(.system(size: 10, weight: .bold))
                .tracking(1)

            Text(verbatim: summary.shippedDate ?? "—")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
        }
        .foregroundStyle(summary.level.accent)
        .frame(width: 76, height: 76)
        .overlay {
            Circle()
                .strokeBorder(summary.level.accent, style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
        }
        .rotationEffect(.degrees(-12))
    }
}

#Preview {
    VStack(spacing: 0) {
        ForEach(Stability.Level.allCases, id: \.self) { level in
            VersionSummaryHeader(
                summary: VersionSummary(
                    release: [ReleaseHealth].samples.first { $0.freeSessions.level == level } ?? [ReleaseHealth].samples[0],
                    trend: .sample
                )
            )
        }
    }
}

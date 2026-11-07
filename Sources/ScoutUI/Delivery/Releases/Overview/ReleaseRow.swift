//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReleaseRow: View {
    let release: ReleaseHealth
    let showsDivider: Bool

    var body: some View {
        Row {
            HStack(spacing: 12) {
                ring

                VStack(alignment: .leading, spacing: 3) {
                    Text(verbatim: release.id)
                        .font(.system(size: 17, weight: .bold, design: .monospaced))

                    Text(verbatim: "\(release.adoption.formatted) of sessions · \(DateFormatter.monthDay.string(from: release.released))")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(.systemGray))
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 3) {
                    Text(verbatim: release.freeSessions.formatted)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))

                    Text(verbatim: release.freeSessions.level.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(release.freeSessions.level.tint)
                }
            }
            .padding(.vertical, 8)
            .frame(minHeight: 64)
            .overlay(alignment: .bottom) {
                if showsDivider {
                    DashedLine()
                }
            }
            .accessibilityElement(children: .combine)
        } destination: {
            ReleaseView(release: release)
        }
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 3)

            Circle()
                .trim(from: 0, to: release.adoption.value)
                .stroke(release.freeSessions.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 30, height: 30)
        .accessibilityHidden(true)
    }
}

#Preview {
    NavigationStack {
        InsetList {
            ForEach(Array([ReleaseHealth].samples.enumerated()), id: \.element.id) { index, release in
                ReleaseRow(release: release, showsDivider: index < 4)
            }
        }
        .navigationTitle(en: "Releases")
    }
}

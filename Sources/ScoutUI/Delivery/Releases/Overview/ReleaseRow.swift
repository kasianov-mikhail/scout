//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReleaseRow: View {
    let release: ReleaseHealth
    let isLast: Bool

    var body: some View {
        Row {
            ReleaseRing(adoption: release.adoption, color: release.freeSessions.color)

            VStack(alignment: .leading, spacing: 3) {
                Text(verbatim: release.id)
                    .font(.system(size: 17, weight: .bold, design: .monospaced))
                    .lineLimit(1)

                Text(verbatim: release.adoptionLabel)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.systemGray))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 3) {
                Text(verbatim: release.freeSessions.formatted)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))

                Text(verbatim: release.freeSessions.level.displayTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(release.freeSessions.level.labelColor)
            }
        } destination: {
            VersionDetailView(release: release)
        }
        .padding(.vertical, 8)
        .frame(minHeight: 64)
        .overlay(alignment: .bottom) {
            if !isLast {
                DashedLine()
            }
        }
    }
}

private struct ReleaseRing: View {
    let adoption: Adoption
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .inset(by: 1.5)
                .stroke(Color(.systemGray5), lineWidth: 3)
            Circle()
                .inset(by: 1.5)
                .trim(from: 0, to: adoption.value)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 30, height: 30)
    }
}

#Preview {
    let releases = [ReleaseHealth].samples

    return NavigationStack {
        InsetList {
            ForEach(Array(releases.enumerated()), id: \.element.id) { index, release in
                ReleaseRow(release: release, isLast: index == releases.count - 1)
                    .listRowSeparator(.hidden)
            }
        }
        .navigationTitle(en: "Releases")
    }
}

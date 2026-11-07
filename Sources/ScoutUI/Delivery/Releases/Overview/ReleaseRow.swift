//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ReleaseRow: View {
    let release: ReleaseHealth
    let showsSeparator: Bool

    var body: some View {
        Row {
            HStack(spacing: 12) {
                ReleaseRing(release: release)

                VStack(alignment: .leading, spacing: 3) {
                    Text(verbatim: release.id)
                        .font(.system(size: 17, weight: .bold, design: .monospaced))

                    Text(verbatim: release.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(.systemGray))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 3) {
                    Text(verbatim: release.freeSessions.formatted)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .monospacedDigit()

                    Text(verbatim: release.freeSessions.level.displayTitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(release.freeSessions.level.accent)
                }
            }
        } destination: {
            VersionDetailView(release: release)
        }
        .frame(minHeight: 64)
        .overlay(alignment: .bottom) {
            if showsSeparator {
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
                .stroke(Color(.systemGray5), lineWidth: 3)

            Circle()
                .trim(from: 0, to: adoption.value)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 30, height: 30)
        .accessibilityHidden(true)
    }
}

extension ReleaseRing {
    init(release: ReleaseHealth) {
        self.init(adoption: release.adoption, color: release.freeSessions.level.color)
    }
}

#Preview {
    let releases = [ReleaseHealth].samples

    return NavigationStack {
        InsetList {
            ForEach(releases) { release in
                ReleaseRow(release: release, showsSeparator: release.id != releases.last?.id)
                    .listRowSeparator(.hidden)
            }
        }
        .navigationTitle(en: "Releases")
    }
}

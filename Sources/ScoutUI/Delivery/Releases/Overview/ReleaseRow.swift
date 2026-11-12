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
        NavigationLink {
            ReleaseView(release: release)
        } label: {
            HStack(spacing: .space8) {
                ReleaseRing(adoption: release.adoption, color: release.freeSessions.color)

                VStack(alignment: .leading, spacing: .space2) {
                    Text(verbatim: release.id)
                        .font(.scoutRowMonoStrong)
                        .lineLimit(1)

                    Text(verbatim: release.adoptionLabel)
                        .font(.scoutCaption)
                        .foregroundStyle(Color.textMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: .space2) {
                    Text(verbatim: release.freeSessions.formatted)
                        .font(.scoutRowMonoStrong)

                    Text(verbatim: release.freeSessions.level.displayTitle)
                        .font(.scoutFootnoteStrong)
                        .foregroundStyle(release.freeSessions.level.labelColor)
                }
            }
            .lineLimit(1)
            .frame(height: .rowChart)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
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
                .stroke(Color.surfaceSkeleton, lineWidth: 3)
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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(releases.enumerated()), id: \.element.id) { index, release in
                    ReleaseRow(release: release, isLast: index == releases.count - 1)
                }
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(en: "Releases")
    }
}

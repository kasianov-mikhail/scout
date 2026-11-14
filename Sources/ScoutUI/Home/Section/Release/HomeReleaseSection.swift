//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeReleaseSection: View {
    let adoption: ReleaseAdoption?
    let onShowAll: () -> Void

    @Environment(\.homeTypography) private var typography

    var body: some View {
        if let adoption {
            if adoption.isEmpty {
                HomeReleaseSectionEmpty(onShowAll: onShowAll)
            } else {
                content(adoption: adoption)
            }
        } else {
            HomeReleaseSectionPlaceholder()
        }
    }

    private func content(adoption: ReleaseAdoption) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(title: "Releases", showsSeparator: true, font: typography.font(.section)) {
                HomeSectionExpandButton(label: "Show all releases", action: onShowAll)
            }

            HStack(alignment: .firstTextBaseline, spacing: .space8) {
                Text(verbatim: adoption.headline)
                    .homeText(.headline)

                Text(verbatim: "of sessions")
                    .homeText(.suffix)
            }
            .frame(height: 28)
            .padding(.top, 14)

            AdoptionBar(
                versions: adoption.versions,
                height: 24,
                labelSize: 10,
                labelWeight: .semibold,
                labelInset: 6,
                labelFont: typography.font(.stripLabel),
                labelTracking: typography.tracking(.stripLabel)
            )
            .padding(.top, .space10)

            AdoptionLegend(
                squareSize: 7,
                squareColor: nil,
                font: typography.font(.legend),
                color: typography.color(.legend)
            )
            .padding(.top, .space8)

            caption(adoption: adoption)
                .padding(.top, .space10)
                .padding(.bottom, .space6)
        }
    }

    @ViewBuilder
    private func caption(adoption: ReleaseAdoption) -> some View {
        if let top = adoption.top {
            (Text(verbatim: "\(top.id) is ")
                .foregroundColor(typography.color(.caption))
                + Text(verbatim: top.stability.level.title)
                .font(typography.font(.status))
                .foregroundColor(top.stability.level == .healthy ? Color.positive : top.stability.level.labelColor)
                + Text(verbatim: " at \(top.stability.formatted) crash-free\(top.shippedLabel)")
                .foregroundColor(typography.color(.caption)))
                .homeText(.caption)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeReleaseSection(adoption: .sample) {}
                HomeReleaseSection(adoption: nil) {}
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}

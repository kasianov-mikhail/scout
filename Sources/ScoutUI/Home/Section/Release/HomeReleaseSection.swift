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

    var body: some View {
        if let adoption {
            content(adoption: adoption)
        } else {
            HomeReleaseSectionPlaceholder()
        }
    }

    private func content(adoption: ReleaseAdoption) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(title: "Releases") {
                Button(action: onShowAll) {
                    Image(systemName: "arrow.up.right.and.arrow.down.left")
                        .font(.weight450(size: 20))
                        .frame(width: 44, height: 44)
                        .padding(.trailing, -12)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
                .accessibilityLabel(Text(verbatim: "Show all releases"))
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(verbatim: adoption.headline)
                    .font(.system(size: 24, weight: .bold))

                Text(verbatim: "of sessions")
                    .font(.weight450(size: 15))
                    .foregroundStyle(Color(.systemGray))
            }

            AdoptionBar(
                versions: adoption.versions,
                height: 24,
                labelSize: 10,
                labelWeight: .semibold,
                labelInset: 6
            )
            .padding(.top, 10)

            AdoptionLegend(squareSize: 7, squareColor: nil)
                .padding(.top, 8)

            caption(adoption: adoption)
                .padding(.top, 10)
                .padding(.bottom, 6)
        }
    }

    @ViewBuilder
    private func caption(adoption: ReleaseAdoption) -> some View {
        if let top = adoption.top {
            (Text(verbatim: "\(top.id) is ")
                .foregroundColor(Color(.systemGray))
                + Text(verbatim: top.stability.level.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(top.stability.level == .healthy ? Color.positive : top.stability.level.labelColor)
                + Text(verbatim: " at \(top.stability.formatted) crash-free\(top.shippedLabel)")
                .foregroundColor(Color(.systemGray)))
                .font(.weight450(size: 13))
        }
    }
}

#Preview {
    NavigationStack {
        InsetList {
            HomeReleaseSection(adoption: .sample) {}
                .frame(minHeight: 44)
            HomeReleaseSection(adoption: nil) {}
                .frame(minHeight: 44)
        }
    }
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeReleaseSection: View {
    let adoption: ReleaseAdoption
    let onShowAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(title: "Releases") {
                Button(action: onShowAll) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 20))
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
                    .font(.subheadline)
                    .foregroundStyle(Color(.systemGray))
            }

            AdoptionBar(versions: adoption.versions)
                .padding(.top, 10)

            legend
                .padding(.top, 6)

            caption
                .padding(.top, 10)
                .padding(.bottom, 6)
        }
        .listRowSeparator(.hidden)
    }

    private var legend: some View {
        HStack(spacing: 12) {
            ForEach(Stability.Level.allCases, id: \.self) { level in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(level.color)
                        .frame(width: 7, height: 7)

                    Text(verbatim: level.title)
                }
            }
        }
        .font(.caption)
        .foregroundStyle(Color(.systemGray))
    }

    @ViewBuilder
    private var caption: some View {
        if let top = adoption.top {
            (Text(verbatim: "\(top.id) is ")
                .foregroundColor(Color(.systemGray))
                + Text(verbatim: top.stability.level.title)
                .fontWeight(.semibold)
                .foregroundColor(top.stability.level.color)
                + Text(verbatim: " at \(top.stability.formatted) crash-free\(top.shippedLabel)")
                .foregroundColor(Color(.systemGray)))
                .font(.footnote)
        }
    }
}

#Preview {
    NavigationStack {
        InsetList {
            HomeReleaseSection(adoption: .sample) {}
        }
    }
}

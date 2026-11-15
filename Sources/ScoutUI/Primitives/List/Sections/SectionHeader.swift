//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SectionHeader<Trailing: View>: View {
    let titles: [String]
    let showsSeparator: Bool

    @ViewBuilder let trailing: () -> Trailing

    init(title: String, showsSeparator: Bool = true, @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.init(titles: [title], showsSeparator: showsSeparator, trailing: trailing)
    }

    init(titles: [String], showsSeparator: Bool = true, @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.titles = titles
        self.showsSeparator = showsSeparator
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(titles.indices, id: \.self) { index in
                Text(verbatim: titles[index].uppercased())
                    .font(.scoutSection)
                    .padding(.leading, index == 0 ? 0 : .space12)
                    .frame(maxWidth: titles.count > 1 ? .infinity : nil, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
            }

            if titles.count == 1 {
                Spacer()
            }

            trailing()
        }
        .frame(height: .sectionHeaderHeight)
        .overlay(alignment: .bottom) {
            if showsSeparator {
                Separator()
            }
        }
    }
}

#Preview {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            SectionGap()
            SectionHeader(title: "HISTORY")
            SectionHeader(title: "SESSIONS") {
                Text(verbatim: "TIMELINE")
                    .font(.scoutSectionAction)
                    .foregroundStyle(Color.textLink)
            }
            SectionGap()
            SectionHeader(titles: ["TELEMETRY", "INCIDENTS"])
            SectionHeader(title: "DEVICES", showsSeparator: false)
        }
    }
    .scrollIndicators(.hidden)
}

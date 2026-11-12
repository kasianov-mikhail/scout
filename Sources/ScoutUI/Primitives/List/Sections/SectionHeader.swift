//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SectionHeader<Trailing: View>: View {
    let title: String
    var topPadding: CGFloat = 0
    var showsSeparator = true

    @ViewBuilder let trailing: () -> Trailing

    init(title: String, topPadding: CGFloat = 0, showsSeparator: Bool = true, @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.title = title
        self.topPadding = topPadding
        self.showsSeparator = showsSeparator
        self.trailing = trailing
    }

    var body: some View {
        HStack {
            Text(verbatim: title)
                .font(.system(size: 16, weight: .bold))

            Spacer()

            trailing()
        }
        .padding(.top, topPadding)
        .frame(height: 56)
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
            SectionHeader(title: "HISTORY", topPadding: 12)
            SectionHeader(title: "SESSIONS", topPadding: 12) {
                Text(verbatim: "TIMELINE")
                    .font(.book(size: 16))
                    .foregroundStyle(.blue)
            }
            SectionHeader(title: "DEVICES", showsSeparator: false)
        }
        .padding(.horizontal, 16)
    }
    .scrollIndicators(.hidden)
}

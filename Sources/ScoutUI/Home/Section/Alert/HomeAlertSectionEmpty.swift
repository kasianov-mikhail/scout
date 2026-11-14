//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeAlertSectionEmpty: View {
    let rulesLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: .space6) {
            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: "ALERTS")
                    .homeText(.labelInk)

                Spacer()

                Text(verbatim: rulesLabel)
                    .homeText(.caption)
            }

            HStack(spacing: .space2) {
                ForEach(0..<24) { _ in
                    EmptyBar(height: 10, cornerRadius: .radiusBar)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, .space6)

            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: "No rules yet")

                Spacer()

                Text(verbatim: "Add rule")
                    .foregroundStyle(Color.textLink)
            }
            .homeText(.caption)
            .padding(.top, .space2)
        }
        .padding(.top, .space12)
        .padding(.bottom, .space12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
        .padding(.bottom, .space4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeAlertSectionEmpty(rulesLabel: "0 rules")
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}

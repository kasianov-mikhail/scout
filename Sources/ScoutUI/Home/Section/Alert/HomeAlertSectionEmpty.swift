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
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: "ALERTS")
                    .font(.footnote.weight(.semibold))

                Spacer()

                Text(verbatim: rulesLabel)
                    .font(.weight450(size: 13))
                    .foregroundStyle(Color(.systemGray))
            }

            HStack(spacing: 2) {
                ForEach(0..<24) { _ in
                    EmptyBar(height: 10, cornerRadius: 2)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 4)

            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: "No rules yet")

                Spacer()

                Text(verbatim: "Add rule")
                    .foregroundStyle(.blue)
            }
            .font(.weight450(size: 13))
            .foregroundStyle(Color(.systemGray))
            .padding(.top, 2)
        }
        .padding(.top, 12)
        .padding(.bottom, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
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
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
    }
}

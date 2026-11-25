//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension HomeAlertSection {
    struct Empty: View {
        let rulesLabel: String

        var body: some View {
            VStack(alignment: .leading, spacing: .space6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(verbatim: "ALERTS")
                        .font(.scoutCaptionStrong)

                    Spacer()

                    Text(verbatim: rulesLabel)
                        .font(.scoutCaption)
                        .foregroundStyle(Color.textMuted)
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
                .font(.scoutCaption)
                .foregroundStyle(Color.textMuted)
                .padding(.top, .space2)
            }
            .padding(.top, .space12)
            .padding(.bottom, .space16)
            .contentShape(Rectangle())
            .accessibilityElement(children: .combine)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeAlertSection.Empty(rulesLabel: "0 rules")
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}

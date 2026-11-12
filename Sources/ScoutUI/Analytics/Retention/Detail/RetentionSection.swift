//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RetentionSection: View {
    let title: String
    var note: String?
    var divider = false

    var body: some View {
        HStack(spacing: .space6) {
            Text(verbatim: title.uppercased())
                .font(.scoutSection)

            Spacer()

            if let note {
                Text(verbatim: divider ? "│ \(note)" : note)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            }
        }
        .padding(.top, .space12)
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}

#Preview {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            RetentionSection(title: "Come back on", note: "average of 7 weeks", divider: true)
            RetentionSection(title: "By OS version", note: "day 7")
            RetentionSection(title: "Stability")
        }
        .padding(.horizontal, .gutter)
    }
    .scrollIndicators(.hidden)
}

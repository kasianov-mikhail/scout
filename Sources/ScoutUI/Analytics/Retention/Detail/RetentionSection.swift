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
        HStack(spacing: 6) {
            Text(verbatim: title.uppercased())
                .font(.system(size: 16, weight: .bold))

            Spacer()

            if let note {
                if divider {
                    Rectangle()
                        .fill(Color.separator)
                        .frame(width: 0.5, height: 13)
                }

                Text(verbatim: note)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.systemGray))
            }
        }
        .padding(.top, 12)
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}

#Preview {
    InsetList {
        RetentionSection(title: "Come back on", note: "average of 7 weeks", divider: true)
        RetentionSection(title: "By OS version", note: "day 7")
        RetentionSection(title: "Stability")
    }
}

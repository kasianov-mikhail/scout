//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ColumnHeader: View {
    let title: String
    var color = Color(.systemGray)

    var body: some View {
        Text(verbatim: title)
            .font(.system(size: 11, weight: .semibold))
            .tracking(0.3)
            .foregroundStyle(color)
    }
}

extension View {
    func columnHeaderStyle(topPadding: CGFloat = 14) -> some View {
        padding(.top, topPadding)
            .padding(.bottom, 8)
            .overlay(alignment: .bottom) {
                Separator()
            }
    }
}

#Preview {
    InsetList {
        HStack(spacing: 8) {
            ColumnHeader(title: "SESSIONS")
                .frame(maxWidth: .infinity, alignment: .leading)
            ColumnHeader(title: "OS")
                .frame(width: 112, alignment: .leading)
            ColumnHeader(title: "CRASHES")
                .frame(width: 56, alignment: .trailing)
        }
        .columnHeaderStyle()
        .frame(minHeight: 44)

        HStack(spacing: 8) {
            ColumnHeader(title: "REQUESTS ↓", color: .blue)
                .frame(maxWidth: .infinity, alignment: .leading)
            ColumnHeader(title: "OK")
                .frame(width: 56, alignment: .trailing)
            ColumnHeader(title: "P99")
                .frame(width: 64, alignment: .trailing)
        }
        .columnHeaderStyle(topPadding: 12)
        .frame(minHeight: 44)
    }
}

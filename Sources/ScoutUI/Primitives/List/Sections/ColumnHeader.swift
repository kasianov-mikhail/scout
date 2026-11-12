//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ColumnHeader: View {
    let title: String
    var color = Color.fillLevel

    var body: some View {
        Text(verbatim: title)
            .font(.scoutLabelCaps)
            .tracking(0.3)
            .foregroundStyle(color)
    }
}

extension View {
    func columnHeaderStyle(topPadding: CGFloat = 14) -> some View {
        padding(.top, topPadding)
            .padding(.bottom, .space8)
            .overlay(alignment: .bottom) {
                Separator()
            }
    }
}

#Preview {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            HStack(spacing: .space8) {
                ColumnHeader(title: "SESSIONS")
                    .frame(maxWidth: .infinity, alignment: .leading)
                ColumnHeader(title: "OS")
                    .frame(width: 112, alignment: .leading)
                ColumnHeader(title: "CRASHES")
                    .frame(width: 56, alignment: .trailing)
            }
            .columnHeaderStyle()

            HStack(spacing: .space8) {
                ColumnHeader(title: "REQUESTS ↓", color: .textLink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ColumnHeader(title: "OK")
                    .frame(width: 56, alignment: .trailing)
                ColumnHeader(title: "P99")
                    .frame(width: 64, alignment: .trailing)
            }
            .columnHeaderStyle(topPadding: 12)
        }
        .padding(.horizontal, .gutter)
    }
    .scrollIndicators(.hidden)
}

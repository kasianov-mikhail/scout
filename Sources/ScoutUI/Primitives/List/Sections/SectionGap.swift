//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SectionGap: View {
    var body: some View {
        Color.surfaceGrey
            .frame(height: .sectionGap)
            .overlay(alignment: .top) {
                Separator(color: .lineGap)
            }
            .overlay(alignment: .bottom) {
                Separator(color: .lineGap)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 0) {
        Text(verbatim: "Content above")
            .padding(.horizontal, .gutter)
        SectionGap()
        Text(verbatim: "Content below")
            .padding(.horizontal, .gutter)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
}

//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ListTitle: View {
    let title: String

    var body: some View {
        Text(verbatim: title)
            .font(.scoutNumberL)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, .space8)
    }
}

#Preview {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            ListTitle(title: "Today")
        }
        .padding(.horizontal, .gutter)
    }
    .scrollIndicators(.hidden)
}

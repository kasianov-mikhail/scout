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
            .font(.listTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
}

#Preview {
    InsetList {
        ListTitle(title: "Today")
            .frame(minHeight: 44)
    }
}

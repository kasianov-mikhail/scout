//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Header<Trailing: View>: View {
    let title: String

    @ViewBuilder let trailing: () -> Trailing

    init(title: String, @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        HStack {
            Text(verbatim: title.uppercased()).font(.scoutSection)

            Spacer()

            trailing()
        }
        .padding(.top, .space12)
        .frame(height: 70)
    }
}

#Preview {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            Header(title: "Section Title")
            Header(title: "Section Title") {
                Text(verbatim: "Trailing")
            }
        }
        .padding(.horizontal, .gutter)
    }
    .scrollIndicators(.hidden)
}

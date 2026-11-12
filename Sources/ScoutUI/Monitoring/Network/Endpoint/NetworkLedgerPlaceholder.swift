//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct NetworkLedgerPlaceholder: View {
    let title: String
    let primary: String

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ListTitle(title: title)

                NetworkEndpointHeaderPlaceholder()

                NetworkLedgerHeader(primary: primary)

                ForEach(0..<14, id: \.self) { index in
                    NetworkLedgerRowPlaceholder(index: index, showsDivider: index < 13)
                }
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }
}
